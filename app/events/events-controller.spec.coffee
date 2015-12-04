require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../common/meteor/meteor-mocks'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $q = null
  $state = null
  $meteor = null
  Auth = null
  commentsCollection = null
  ctrl = null
  Event = null
  SavedEvent = null
  scope = null
  ngToast = null
  RecommendedEvent = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ngToast')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $meteor = $injector.get '$meteor'
    Auth = $injector.get 'Auth'
    Event = $injector.get 'Event'
    SavedEvent = $injector.get 'SavedEvent'
    scope = $injector.get '$rootScope'
    ngToast = $injector.get 'ngToast'
    RecommendedEvent = $injector.get 'RecommendedEvent'

    # Mock the current user.
    Auth.user = {id: 1}

    ctrl = $controller EventsCtrl,
      $scope: scope
  )

  it 'should set the current user on the controller', ->
    expect(ctrl.currentUser).toBe Auth.user

  ##$ionicView.loaded
  describe 'the first time that the view is loaded', ->

    beforeEach ->
      spyOn ctrl, 'refresh'

      scope.$emit '$ionicView.loaded'
      scope.$apply()

    it 'should set a loading flag', ->
      expect(ctrl.isLoading).toBe true

    it 'should refresh the data', ->
      expect(ctrl.refresh).toHaveBeenCalled()


  ##handleLoadedData
  describe 'handling after new data loads', ->
    items = null

    beforeEach ->
      items = []
      spyOn(ctrl, 'buildItems').and.returnValue items
      ctrl.isLoading = true

    describe 'when all of the data has loaded', ->

      beforeEach ->
        spyOn scope, '$broadcast'
        ctrl.savedEventsLoaded = true
        ctrl.recommendedEventsLoaded = true
        ctrl.commentsCountLoaded = true

        ctrl.handleLoadedData()

      it 'should stop the refresher', ->
        expect(scope.$broadcast).toHaveBeenCalledWith 'scroll.refreshComplete'

      it 'should clear the loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should build the items', ->
        expect(ctrl.buildItems).toHaveBeenCalled()

      it 'should set the items on the controller', ->
        expect(ctrl.items).toBe items


  ##refresh
  describe 'pull to refresh', ->

    beforeEach ->
      ctrl.savedEventsLoaded = true
      ctrl.recommendedEventsLoaded = true
      ctrl.commentsCountLoaded = true

      spyOn ctrl, 'getSavedEvents'
      spyOn ctrl, 'getRecommendedEvents'

      ctrl.refresh()

    it 'should clear the loaded flags', ->
      expect(ctrl.savedEventsLoaded).toBe undefined
      expect(ctrl.recommendedEventsLoaded).toBe undefined
      expect(ctrl.commentsCountLoaded).toBe undefined

    it 'should get the events', ->
      expect(ctrl.getSavedEvents).toHaveBeenCalled()

    it 'should get the recommended events', ->
      expect(ctrl.getRecommendedEvents).toHaveBeenCalled()


  ##buildItems
  describe 'building the items', ->
    savedEvent = null
    savedEventItem = null
    savedEventFromRecommendedEvent = null
    savedEventFromRecommendedEventItem = null
    recommendedEvent = null
    recommendedEventItem = null
    recommendedEventsDivider = null

    beforeEach ->
      ctrl.commentsCount =
        '1': 1
        '2': 1
      savedEvent =
        id: 1
        eventId: 1
      savedEventItem =
        isDivider: false
        savedEvent: savedEvent
        commentsCount: 1

      savedEventFromRecommendedEvent =
        id: 2
        eventId: 2
        event:
          recommendedEvent: 1
      savedEventFromRecommendedEventItem =
        isDivider: false
        savedEvent: savedEventFromRecommendedEvent
        commentsCount: 1

      recommendedEvent =
        id: 1
      recommendedEventsDivider =
        isDivider: true
        title: 'Recommended'
      recommendedEventItem =
        isDivider: false
        recommendedEvent: recommendedEvent

    describe 'when there are saved events and recommended events', ->

      it 'should build the items', ->
        ctrl.savedEvents = [savedEvent]
        ctrl.recommendedEvents = [recommendedEvent]
        expectedItems = [
          savedEventItem
        ,
          recommendedEventsDivider
        ,
          recommendedEventItem
        ]
        expect(ctrl.buildItems()).toEqual expectedItems


    describe 'when a saved event is created from a recommended event', ->

      it 'should build the items', ->
        ctrl.savedEvents = [savedEvent, savedEventFromRecommendedEvent]
        ctrl.recommendedEvents = [recommendedEvent]
        expectedItems = [
          savedEventItem
        ,
          savedEventFromRecommendedEventItem
        ]
        expect(ctrl.buildItems()).toEqual expectedItems


    describe 'when there are no saved events', ->

      it 'should build the items', ->
        ctrl.savedEvents = []
        ctrl.recommendedEvents = [recommendedEvent]
        expectedItems = [
          recommendedEventsDivider
        ,
          recommendedEventItem
        ]
        expect(ctrl.buildItems()).toEqual expectedItems


    describe 'when there are no recommended events', ->

      it 'should build the items', ->
        ctrl.savedEvents = [savedEvent]
        ctrl.recommendedEvents = []
        expectedItems = [
          savedEventItem
        ]
        expect(ctrl.buildItems()).toEqual expectedItems


  ##getSavedEvents
  describe 'getting the feed of events', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(SavedEvent, 'query').and.returnValue {$promise: deferred.promise}

      ctrl.getSavedEvents()

    it 'should query saved events from the server', ->
      expect(SavedEvent.query).toHaveBeenCalled()

    describe 'when successful', ->
      response = null

      beforeEach ->
        spyOn ctrl, 'handleLoadedData'
        spyOn ctrl, 'getCommentsCount'
        response = []

        deferred.resolve response
        scope.$apply()

      it 'should set the saved events on the controller', ->
        expect(ctrl.savedEvents).toBe response

      it 'should set the events loaded flag', ->
        expect(ctrl.savedEventsLoaded).toBe true

      it 'should handle the loaded data', ->
        expect(ctrl.handleLoadedData).toHaveBeenCalled()

      it 'should get the comments count', ->
        expect(ctrl.getCommentsCount).toHaveBeenCalled()


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ngToast.create).toHaveBeenCalledWith 'Oops.. an error occurred..'


  ##getRecommendedEvents
  describe 'getting the recommended events', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(RecommendedEvent, 'query') \
        .and.returnValue {$promise: deferred.promise}

      ctrl.getRecommendedEvents()

    it 'should query for the recommended events', ->
      expect(RecommendedEvent.query).toHaveBeenCalled()

    describe 'when successful', ->
      response = null

      beforeEach ->
        response = []
        spyOn ctrl, 'handleLoadedData'

        deferred.resolve response
        scope.$apply()

      it 'should set the recommended events on the controller', ->
        expect(ctrl.recommendedEvents).toBe response

      it 'should set the recommended events loaded flag', ->
        expect(ctrl.recommendedEventsLoaded).toBe true

      it 'should handle the data', ->
        expect(ctrl.handleLoadedData).toHaveBeenCalled()


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ngToast.create).toHaveBeenCalledWith 'Oops.. an error occurred..'


  ##getCommentsCount
  describe 'getting the comments count', ->
    event = null
    deferred = null

    beforeEach ->
      event =
        id: 1
      savedEvent =
        event: event
        eventId: event.id
      ctrl.savedEvents = [savedEvent]
      deferred = $q.defer()
      $meteor.call.and.returnValue deferred.promise

      ctrl.getCommentsCount()

    it 'should get the comments count', ->
      expect($meteor.call).toHaveBeenCalledWith 'getCommentsCount', [event.id]

    describe 'successfully', ->
      count = null

      beforeEach ->
        count = 1
        commentsCount = [
          _id: "#{event.id}"
          count: count
        ]
        spyOn ctrl, 'handleLoadedData'
        deferred.resolve commentsCount
        scope.$apply()

      it 'should save the comments count on the controller as an object', ->
        commentsCountObj = {}
        commentsCountObj[event.id] = count
        expect(ctrl.commentsCount).toEqual commentsCountObj

      it 'should set the commentsCount loaded flag', ->
        expect(ctrl.commentsCountLoaded).toBe true

      it 'should handle the loaded data', ->
        expect(ctrl.handleLoadedData).toHaveBeenCalled()


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'
        deferred.reject()
        scope.$apply()

      it 'should throw an error', ->
        expect(ngToast.create).toHaveBeenCalled()


  ##createEvent
  describe 'creating an event', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.createEvent()

    it 'should go to the create event view', ->
      expect($state.go).toHaveBeenCalledWith 'createEvent'


  ##saveRecommendedEvent
  describe 'saving a recommended event', ->
    recommendedEvent = null
    deferred = null
    expectedEvent = null

    beforeEach ->
      recommendedEvent =
        id: 1
        title: 'Going up on a Tuesday'
        datetime: new Date()
        place:
          name: 'Bar bar'
          lat: 40.6785872
          long: -74.0419964

      deferred = $q.defer()
      spyOn(Event, 'save').and.returnValue {$promise: deferred.promise}

      expectedEvent = angular.extend {}, recommendedEvent
      delete expectedEvent.id
      expectedEvent.recommendedEvent = recommendedEvent.id

      ctrl.saveRecommendedEvent recommendedEvent

    it 'should create an event from the recommended event', ->
      expect(Event.save).toHaveBeenCalledWith expectedEvent

    it 'should set a was saved flag', ->
      expect(recommendedEvent.wasSaved).toBe true

    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'should remove the was saved flag', ->
        expect(recommendedEvent.wasSaved).toBe undefined

      it 'should show an error', ->
        expect(ngToast.create).toHaveBeenCalled()
