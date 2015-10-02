require '../ionic/ionic.js' # for ionic module
require 'angular'
require 'angular-animate' # for ionic module
require 'angular-mocks'
require 'angular-sanitize' # for ionic module
require 'angular-ui-router'
require '../ionic/ionic-angular.js' # for ionic module
require 'ng-cordova'
CreateEventCtrl = require './create-event-controller'

describe 'create event controller', ->
  $cordovaDatePicker = null
  $filter = null
  $ionicHistory = null
  $ionicModal = null
  $q = null
  $state = null
  ctrl = null
  deferredTemplate = null
  scope = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngCordova')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $cordovaDatePicker = $injector.get '$cordovaDatePicker'
    $filter = $injector.get '$filter'
    $ionicHistory = $injector.get '$ionicHistory'
    $ionicModal = $injector.get '$ionicModal'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    scope = $injector.get '$rootScope'

    deferredTemplate = $q.defer()
    spyOn($ionicModal, 'fromTemplateUrl').and.returnValue deferredTemplate.promise

    ctrl = $controller CreateEventCtrl,
      $scope: scope
  )

  it 'should init a set place modal', ->
    templateUrl = 'app/set-place/set-place.html'
    expect($ionicModal.fromTemplateUrl).toHaveBeenCalledWith templateUrl,
      scope: scope
      animation: 'slide-in-up'

  describe 'when entering the view', ->

    beforeEach ->
      spyOn $ionicHistory, 'nextViewOptions'

      scope.$broadcast '$ionicView.enter'
      scope.$apply()

    it 'should disable animating the transition to the next view', ->
      options = {disableAnimate: true}
      expect($ionicHistory.nextViewOptions).toHaveBeenCalledWith options


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


  describe 'inviting friends', ->
    newEvent = null

    beforeEach ->
      newEvent = 'newEvent'
      spyOn(ctrl, 'getNewEvent').and.returnValue newEvent
      spyOn $state, 'go'

      ctrl.inviteFriends()

    it 'should get the new event', ->
      expect(ctrl.getNewEvent).toHaveBeenCalled()

    it 'should go to the invite friends view', ->
      expect($state.go).toHaveBeenCalledWith 'inviteFriends', {event: newEvent}


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

        newEvent = ctrl.getNewEvent()

      it 'should return the event', ->
        event =
          title: ctrl.title
          datetime: ctrl.datetime
          place: ctrl.place
        expect(newEvent).toEqual event


    describe 'when the title isn\'t set', ->

      beforeEach ->
        ctrl.title = null
        ctrl.datetime = null
        ctrl.place = null

        newEvent = ctrl.getNewEvent()

      it 'should return the event', ->
        event =
          title: 'Let\'s do something'
        expect(newEvent).toEqual event
