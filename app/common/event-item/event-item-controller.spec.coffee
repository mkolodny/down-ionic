require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../meteor/meteor-mocks'
EventItemCtrl = require './event-item-controller'

describe 'event item directive', ->
  $q = null
  $state = null
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

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    SavedEvent = $injector.get 'SavedEvent'
    scope = $injector.get '$rootScope'
    ngToast = $injector.get 'ngToast'

    Auth.user =
        id: 1
    event =
      id: 1
    savedEvent =
      event: event
      eventId: event.id
      userId: 4
      totalNumInterested: 1

    ctrl = $controller EventItemCtrl
    ctrl.savedEvent = savedEvent
  )

  ##saveEvent
  describe 'saving an event', ->
    deferred = null
    preSaveNumInterested = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(SavedEvent, 'save').and.returnValue {$promise: deferred.promise}

      preSaveNumInterested = ctrl.savedEvent.totalNumInterested
      ctrl.saveEvent()

    it 'should create a new SavedEvent object', ->
      expect(SavedEvent.save).toHaveBeenCalledWith
        userId: Auth.user.id
        eventId: event.id

    it 'should mark the current user as interested', ->
      expect(ctrl.didUserSaveEvent()).toBe true

    it 'should increase the total number interested by 1', ->
      expect(ctrl.savedEvent.totalNumInterested).toBe preSaveNumInterested + 1

    describe 'when the save succeeds', ->
      interestedFriends = null

      beforeEach ->
        interestedFriends = ['friend1', 'friend2']
        newSavedEvent = angular.extend {}, savedEvent,
          interestedFriends: interestedFriends

        deferred.resolve newSavedEvent
        scope.$apply()

      it 'should set the interested friends on the item', ->
        expect(ctrl.savedEvent.interestedFriends).toBe interestedFriends


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


  ##didUserSaveEvent
  describe 'checking if the currrent user saved the event', ->

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
