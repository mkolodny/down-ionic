require '../ionic/ionic.js' # for ionic module
require 'angular'
require 'angular-animate' # for ionic module
require 'angular-mocks'
require 'angular-sanitize' # for ionic module
require 'angular-ui-router'
require '../ionic/ionic-angular.js' # for ionic module
require 'ng-cordova'
require 'ng-toast'
require '../common/mixpanel/mixpanel-module'
require '../common/resources/resources-module'
CreateEventCtrl = require './create-event-controller'

describe 'create event controller', ->
  $cordovaDatePicker = null
  $filter = null
  $ionicActionSheet = null
  $ionicHistory = null
  $ionicLoading = null
  $ionicModal = null
  $mixpanel = null
  $q = null
  $state = null
  $window = null
  Auth = null
  ctrl = null
  deferredTemplate = null
  Event = null
  scope = null
  ngToast = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngCordova')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('ngToast')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $cordovaDatePicker = $injector.get '$cordovaDatePicker'
    $filter = $injector.get '$filter'
    $ionicActionSheet = $injector.get '$ionicActionSheet'
    $ionicHistory = $injector.get '$ionicHistory'
    $ionicLoading = $injector.get '$ionicLoading'
    $ionicModal = $injector.get '$ionicModal'
    $mixpanel = $injector.get '$mixpanel'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $window = $injector.get '$window'
    Auth = $injector.get 'Auth'
    Event = $injector.get 'Event'
    scope = $injector.get '$rootScope'
    ngToast = $injector.get 'ngToast'

    deferredTemplate = $q.defer()
    spyOn($ionicModal, 'fromTemplateUrl').and.returnValue deferredTemplate.promise

    # Mock the current user.
    Auth.currentUser = {id: 1}

    ctrl = $controller CreateEventCtrl,
      $scope: scope
  )

  it 'should init a set place modal', ->
    templateUrl = 'app/set-place/set-place.html'
    expect($ionicModal.fromTemplateUrl).toHaveBeenCalledWith templateUrl,
      scope: scope
      animation: 'slide-in-up'

  it 'should set the current user on the controller', ->
    expect(ctrl.currentUser).toBe Auth.user

  describe 'after entering the view', ->

    beforeEach ->
      scope.$emit '$ionicView.afterEnter'
      scope.$apply()

    it 'should hide the nav border', ->
      expect(scope.hideNavBottomBorder).toBe true


  describe 'after leaving the view', ->

    beforeEach ->
      scope.$emit '$ionicView.leave'
      scope.$apply()

    it 'should show the nav border', ->
      expect(scope.hideNavBottomBorder).toBe false


  describe 'when the place modal loads', ->
    modal = null

    beforeEach ->
      modal =
        show: jasmine.createSpy 'modal.show'
        remove: jasmine.createSpy 'modal.remove'
        hide: jasmine.createSpy 'modal.hide'
      deferredTemplate.resolve modal
      scope.$apply()

    it 'should save the modal on the controller', ->
      expect(ctrl.setPlaceModal).toBe modal

    describe 'showing the modal', ->

      beforeEach ->
        ctrl.showSetPlaceModal()

      it 'should show the modal', ->
        expect(modal.show).toHaveBeenCalled()


    describe 'then the modal is hidden', ->

      beforeEach ->
        scope.$broadcast '$destroy'
        scope.$apply()

      it 'should clean up the modal', ->
        expect(modal.remove).toHaveBeenCalled()


    describe 'hiding the guest list modal', ->

      beforeEach ->
        scope.hidePlaceModal()

      it 'should hide the modal', ->
        expect(modal.hide).toHaveBeenCalled()


  ##$scope.$on 'placeAutocomplete:placeChanged'
  describe 'when the place changes', ->
    name = null
    lat = null
    lng = null

    beforeEach ->
      spyOn scope, 'hidePlaceModal'

      lat = 40.6785872
      lng = -74.0419964
      name = 'Ample Hills Creamery'
      place =
        name: name
        geometry:
          location:
            lat: -> lat
            lng: -> lng
      scope.$emit 'placeAutocomplete:placeChanged', place
      scope.$apply()

    it 'should set the place', ->
      place =
        name: name
        lat: lat
        long: lng
      expect(ctrl.place).toEqual place

    it 'should hide the place modal', ->
      expect(scope.hidePlaceModal).toHaveBeenCalled()


  ##showDatePicker
  describe 'showing the date picker', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn($cordovaDatePicker, 'show').and.returnValue deferred.promise

    describe 'when no date was set yet', ->
      currentDate = null

      beforeEach ->
        ctrl.datetime = null
        jasmine.clock().install()
        currentDate = new Date()
        jasmine.clock().mockDate currentDate

        ctrl.showDatePicker()

      afterEach ->
        jasmine.clock().uninstall()

      it 'should show the date picker', ->
        options =
          mode: 'datetime' # This can be anything other than 'date' or 'time'
          allowOldDates: false
          doneButtonLabel: 'Set Date'
          date: currentDate
        expect($cordovaDatePicker.show).toHaveBeenCalledWith options

      describe 'then picking a date', ->
        date = null

        beforeEach ->
          date = new Date()
          deferred.resolve date
          scope.$apply()

        it 'should set the date on the controller', ->
          expect(ctrl.datetime).toBe date

        it 'should set the date string', ->
          dateString = $filter('date') ctrl.datetime, "EEE, MMM d 'at' h:mm a"
          expect(ctrl.dateString).toBe dateString


    describe 'when a date was set', ->

      beforeEach ->
        ctrl.datetime = new Date(1443811155535)

        ctrl.showDatePicker()

      it 'should show the date picker', ->
        options =
          mode: 'datetime' # This can be anything other than 'date' or 'time'
          allowOldDates: false
          doneButtonLabel: 'Set Date'
          date: ctrl.datetime
        expect($cordovaDatePicker.show).toHaveBeenCalledWith options


  ##getNewEvent
  describe 'getting the new event', ->
    newEvent = null

    describe 'when everything is set', ->

      beforeEach ->
        ctrl.title = 'bars?!?!?'
        ctrl.datetime = new Date()
        ctrl.place =
          name: 'ice cream'
          lat: 40.6785872
          lng: -74.0419964
        ctrl.friendsOnly = true

        newEvent = ctrl.getNewEvent()

      it 'should return the event', ->
        event =
          title: ctrl.title
          datetime: ctrl.datetime
          place: ctrl.place
          friendsOnly: ctrl.friendsOnly
        expect(newEvent).toEqual event


    describe 'when only the title is set', ->

      beforeEach ->
        ctrl.title = 'bars?!?!?'

        newEvent = ctrl.getNewEvent()

      it 'should return the event', ->
        event =
          title: ctrl.title
        expect(newEvent).toEqual event


  ##createEvent
  describe 'creating an event', ->
    deferred = null
    event = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Event, 'save').and.returnValue {$promise: deferred.promise}

      event =
        title: 'bars?!?'
      spyOn(ctrl, 'getNewEvent').and.returnValue event
      ctrl.title = event.title
      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'

      ctrl.createEvent()

    it 'should save the event', ->
      expect(Event.save).toHaveBeenCalledWith event

    it 'should show a loading spinner', ->
      expect($ionicLoading.show).toHaveBeenCalled()

    describe 'successfully', ->
      deferredCacheClear = null

      beforeEach ->
        deferredCacheClear = $q.defer()
        spyOn($ionicHistory, 'clearCache').and.returnValue \
            deferredCacheClear.promise

        spyOn $mixpanel, 'track'

        deferred.resolve()
        scope.$apply()

      it 'should track in mixpanel', ->
        expect($mixpanel.track).toHaveBeenCalledWith 'Create Event',
          'from recommended': false
          time: angular.isDefined ctrl.datetime
          place: angular.isDefined ctrl.place

      it 'should clear the form', ->
        expect(ctrl.title).toBe undefined
        expect(ctrl.datetime).toBe undefined
        expect(ctrl.place).toBe undefined

      it 'should clear the cache', ->
        expect($ionicHistory.clearCache).toHaveBeenCalled()

      describe 'when the cache is cleared', ->

        beforeEach ->
          spyOn $state, 'go'

          deferredCacheClear.resolve()
          scope.$apply()

        it 'should hide a loading spinner', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'should go the the events feed', ->
          expect($state.go).toHaveBeenCalledWith 'events'


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ngToast.create).toHaveBeenCalledWith 'Oops... an error occurred.'

      it 'should hide a loading spinner', ->
        expect($ionicLoading.hide).toHaveBeenCalled()


  ##changePrivacy
  describe 'changing post privacy settings', ->
    hideActionSheet = null

    beforeEach ->
      hideActionSheet = 'hideActionSheet'
      spyOn($ionicActionSheet, 'show').and.returnValue hideActionSheet
      ctrl.changePrivacy()

    it 'should show an action sheet', ->
      expect($ionicActionSheet.show).toHaveBeenCalledWith
        buttons: [
          text: '<i class="fa fa-link"></i> Connections'
        ,
          text: '<i class="fa fa-users"></i> Friends'
        ]
        cancelText: 'Cancel'
        buttonClicked: ctrl.selectPrivacy

    it 'should set the hideSheet function on the controller', ->
      expect(ctrl.hideActionSheet).toBe hideActionSheet


  ##selectPrivacy
  describe 'selecting a privacy setting', ->
    actionSheetButtonsMap = null

    beforeEach ->
      ctrl.hideActionSheet = jasmine.createSpy 'ctrl.hideActionSheet'
      actionSheetButtonsMap =
        connections: 0
        friends: 1

    describe 'when choosing connections', ->

      beforeEach ->
        ctrl.selectPrivacy actionSheetButtonsMap.connections

      it 'should set the privacy settings to connections', ->
        expect(ctrl.friendsOnly).toBe false

      it 'should hide the action sheet', ->
        expect(ctrl.hideActionSheet).toHaveBeenCalled()


    describe 'when choosing friends', ->

      beforeEach ->
        ctrl.selectPrivacy actionSheetButtonsMap.friends

      it 'should the privacy settings to friends only', ->
        expect(ctrl.friendsOnly).toBe true

      it 'should hide the action sheet', ->
        expect(ctrl.hideActionSheet).toHaveBeenCalled()
