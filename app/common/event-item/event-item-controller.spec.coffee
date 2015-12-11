require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'angular-timeago'
require 'ng-toast'
require '../meteor/meteor-mocks'
require '../mixpanel/mixpanel-module'
EventItemCtrl = require './event-item-controller'

describe 'event item directive', ->
  $filter = null
  $ionicPopup = null
  $ionicScrollDelegate = null
  $q = null
  $state = null
  $mixpanel = null
  Auth = null
  ctrl = null
  event = null
  SavedEvent = null
  savedEvent = null
  scope = null
  ngToast = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ngToast')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach angular.mock.module('yaru22.angular-timeago')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $filter = $injector.get '$filter'
    $ionicPopup = $injector.get '$ionicPopup'
    $ionicScrollDelegate = $injector.get '$ionicScrollDelegate'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $mixpanel = $injector.get '$mixpanel'
    Auth = $injector.get 'Auth'
    SavedEvent = $injector.get 'SavedEvent'
    scope = $injector.get '$rootScope'
    ngToast = $injector.get 'ngToast'

    jasmine.clock().install()
    date = new Date 1438014089235
    jasmine.clock().mockDate date

    Auth.user =
        id: 1
    event =
      id: 1
      title: 'ballllinnn'
    savedEvent =
      event: event
      eventId: event.id
      userId: 4
      totalNumInterested: 1
      createdAt: new Date(date - 10000)

    ctrl = $controller EventItemCtrl
    ctrl.savedEvent = savedEvent
  )

  afterEach ->
    jasmine.clock().uninstall()

  ##saveEvent
  describe 'saving an event', ->
    $event = null
    deferred = null
    preSaveNumInterested = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(SavedEvent, 'save').and.returnValue {$promise: deferred.promise}
      spyOn $ionicScrollDelegate, 'resize'

      preSaveNumInterested = ctrl.savedEvent.totalNumInterested

    describe 'when this isn\'t the user\'s first time', ->

      beforeEach ->
        Auth.flags.hasSavedEvent = true

        ctrl.saveEvent()

      it 'should create a new SavedEvent object', ->
        expect(SavedEvent.save).toHaveBeenCalledWith
          userId: Auth.user.id
          eventId: event.id

      it 'should mark the current user as interested', ->
        expect(ctrl.didUserSaveEvent()).toBe true

      it 'should increase the total number interested by 1', ->
        expect(ctrl.savedEvent.totalNumInterested).toBe preSaveNumInterested + 1

      it 'should resize the scroll view', ->
        expect($ionicScrollDelegate.resize).toHaveBeenCalled()

      it 'should set a loading flag', ->
        expect(ctrl.savedEvent.isLoadingInterested).toBe true

      describe 'when the save succeeds', ->
        interestedFriends = null

        beforeEach ->
          interestedFriends = ['friend1', 'friend2']
          newSavedEvent = angular.extend {}, savedEvent,
            interestedFriends: interestedFriends

          spyOn $mixpanel, 'track'
          spyOn ctrl, 'optionallyShowWalkthrough'

          deferred.resolve newSavedEvent
          scope.$apply()

        it 'should track it in mixpanel', ->
          expect($mixpanel.track).toHaveBeenCalledWith 'Save Event',
            'total num interested': preSaveNumInterested
            'time since posted': $filter('timeAgo')(savedEvent.createdAt.getTime())
            'has time': angular.isDefined savedEvent.event.datetime
            'has place': angular.isDefined savedEvent.event.place

        it 'should set the interested friends on the item', ->
          expect(ctrl.savedEvent.interestedFriends).toBe interestedFriends

        it 'should resize the scroll view', ->
          expect($ionicScrollDelegate.resize).toHaveBeenCalled()

        it 'should clear a loading flag', ->
          expect(ctrl.savedEvent.isLoadingInterested).toBe false

        it 'should optionally show the next step of the walkthrough', ->
          expect(ctrl.optionallyShowWalkthrough).toHaveBeenCalled()


      describe 'on error', ->

        beforeEach ->
          spyOn ngToast, 'create'

          deferred.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ngToast.create).toHaveBeenCalled()

        it 'should show the currrent user as not interested', ->
          expect(ctrl.didUserSaveEvent()).toBe false

        it 'should show the original interested number', ->
          expect(ctrl.savedEvent.totalNumInterested).toBe preSaveNumInterested

        it 'should clear a loading flag', ->
          expect(ctrl.savedEvent.isLoadingInterested).toBe false


    describe 'when this is the user\'s first time', ->

      beforeEach ->
        Auth.flags.hasSavedEvent = false
        spyOn Auth, 'setFlag'
        spyOn ctrl, 'showSavedEventPopup'

        ctrl.saveEvent()

      it 'should set a flag', ->
        expect(Auth.setFlag).toHaveBeenCalledWith 'hasSavedEvent', true

      it 'should show a popup', ->
        expect(ctrl.showSavedEventPopup).toHaveBeenCalled()


  ##didUserSaveEvent
  describe 'checking if the current user saved the event', ->

    describe 'when the user has saved the event', ->

      beforeEach ->
        savedEvent.interestedFriends = []

      it 'should return true', ->
        expect(ctrl.didUserSaveEvent savedEvent).toBe true


    describe 'when the user has not saved the event', ->

      beforeEach ->
        delete savedEvent.interestedFriends

      it 'should return false', ->
        expect(ctrl.didUserSaveEvent savedEvent).toBe false


  ##viewComments
  describe 'viewing the comments', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.viewComments()

    it 'should go to the comments view', ->
      expect($state.go).toHaveBeenCalledWith 'comments',
        id: event.id
        event: event


  ##viewInterested
  describe 'viewing people who are interested', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.viewInterested()

    it 'should go to the interested view', ->
      expect($state.go).toHaveBeenCalledWith 'interested',
        id: event.id
        event: event


  ##showSavedEventPopup
  describe 'showing the saved event popup', ->
    popupOptions = null

    beforeEach ->
      spyOn($ionicPopup, 'show').and.callFake (options) ->
        popupOptions = options

      ctrl.showSavedEventPopup()

    it 'should show an ionic popup', ->
      expect($ionicPopup.show).toHaveBeenCalledWith
        title: 'Interested?'
        subTitle: "Tapping <i class=\"calendar-star-default\"></i> indicates that you\'re interested in \"#{event.title}\""
        buttons: [
          text: 'Cancel'
        ,
          text: '<b>Interested</b>'
          onTap: jasmine.any Function
        ]


  ##optionallyShowWalkthrough
  describe 'optionally showing the next step of the walkthrough', ->

    describe 'when the user hasn\'t learned the invite button yet', ->

      beforeEach ->
        delete Auth.flags.hasLearnedInvite

        ctrl.optionallyShowWalkthrough()

      it 'should show the learn invite popup', ->
        expect(ctrl.showLearnInvitePopover).toBe true


  ##setHasLearnedInvite
  describe 'marking the user as having learned the invite button', ->

    beforeEach ->
      spyOn Auth, 'setFlag'
      ctrl.showLearnInvitePopover = true

      ctrl.setHasLearnedInvite()

    it 'should set a flag', ->
      expect(Auth.setFlag).toHaveBeenCalledWith 'hasLearnedInvite', true

    it 'should hide the learn invite popup', ->
      expect(ctrl.showLearnInvitePopover).toBe false
