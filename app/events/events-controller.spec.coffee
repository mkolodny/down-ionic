require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../common/meteor/meteor-mocks'
require '../common/mixpanel/mixpanel-module'
require '../common/points/points-module'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $rootScope = null
  $q = null
  $state = null
  $meteor = null
  $mixpanel = null
  Auth = null
  commentsCollection = null
  ctrl = null
  Event = null
  Points = null
  SavedEvent = null
  scope = null
  ngToast = null
  RecommendedEvent = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.points')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ngToast')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $meteor = $injector.get '$meteor'
    $mixpanel = $injector.get '$mixpanel'
    Auth = $injector.get 'Auth'
    Event = $injector.get 'Event'
    Points = $injector.get 'Points'
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

  it 'should set the points service on the controller', ->
    expect(ctrl.Points).toBe Points

  it 'should set the walkthrough function on the root scope', ->
    expect($rootScope.setHasLearnedSaveEvent).toBe ctrl.setHasLearnedSaveEvent

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


  ##$ionicView.beforeEnter
  describe 'before entering the view', ->

    beforeEach ->
      scope.$broadcast '$ionicView.beforeEnter'
      scope.$apply()

    it 'should show the tab bar', ->
      expect(scope.hideTabBar).toBe false


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
        spyOn ctrl, 'optionallyShowWalkthrough'

        ctrl.handleLoadedData()

      it 'should stop the refresher', ->
        expect(scope.$broadcast).toHaveBeenCalledWith 'scroll.refreshComplete'

      it 'should clear the loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should build the items', ->
        expect(ctrl.buildItems).toHaveBeenCalled()

      it 'should set the items on the controller', ->
        expect(ctrl.items).toBe items

      it 'should optionally show a walkthrough popover', ->
        expect(ctrl.optionallyShowWalkthrough).toHaveBeenCalled()


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
    savedEventsDivider = null
    savedEventFromRecommendedEvent = null
    savedEventFromRecommendedEventItem = null
    recommendedEvent = null
    recommendedEventItem = null
    recommendedEventsDivider = null

    beforeEach ->
      ctrl.commentsCount =
        '1': 1
        '2': 1
      savedEventsDivider =
        isDivider: true
        title: 'Friends'
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
          savedEventsDivider
        ,
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
          savedEventsDivider
        ,
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
          savedEventsDivider
        ,
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


  ##viewEvent
  describe 'viewing an event', ->
    item = null
    savedEvent = null
    commentsCount = null

    beforeEach ->
      savedEvent =
        id: 1
        eventId: 2
      commentsCount = 16
      item =
        savedEvent: savedEvent
        commentsCount: commentsCount
      spyOn $state, 'go'

      ctrl.viewEvent item

    it 'should go to the event view', ->
      expect($state.go).toHaveBeenCalledWith 'home.event',
        savedEvent: item.savedEvent
        recommendedEvent: item.recommendedEvent
        commentsCount: item.commentsCount


  ##optionallyShowWalkthrough
  describe 'optionally showing the walkthrough', ->

    beforeEach ->
      ctrl.savedEvents = []

    describe 'when the user hasn\'t seen a save event button yet', ->

      beforeEach ->
        delete Auth.flags.hasLearnedSaveEvent

        ctrl.optionallyShowWalkthrough()

      it 'should show the learn save event popover', ->
        expect($rootScope.showLearnSaveEventPopover).toBe true


    describe 'when the user has done the save event walkthrough', ->

      beforeEach ->
        Auth.flags.hasLearnedSaveEvent = true

      describe 'but not the learn feed walkthrough', ->

        beforeEach ->
          delete Auth.flags.hasLearnedFeed

        describe 'and the user has saved events', ->

          beforeEach ->
            ctrl.savedEvents = [
              id: 1
            ]

            ctrl.optionallyShowWalkthrough()

          it 'should show the learn feed popover', ->
            expect(ctrl.showLearnFeedPopover).toBe true


  ##setHasLearnedFeed
  describe 'marking that the user has learned how the feed works', ->

    beforeEach ->
      delete Auth.flags.hasLearnedFeed
      spyOn Auth, 'setFlag'
      @showLearnFeedPopover = true

      ctrl.setHasLearnedFeed()

    it 'should set a flag', ->
      expect(Auth.setFlag).toHaveBeenCalledWith 'hasLearnedFeed', true

    it 'should hide the feed', ->
      expect(ctrl.showLearnFeedPopover).toBe false


  describe 'marking that the user has learned the interested button', ->

    beforeEach ->
      delete Auth.flags.hasLearnedSaveEvent
      spyOn Auth, 'setFlag'
      $rootScope.showLearnSaveEventPopover = true
      spyOn ctrl, 'optionallyShowWalkthrough'

      ctrl.setHasLearnedSaveEvent()

    it 'should set a flag', ->
      expect(Auth.setFlag).toHaveBeenCalledWith 'hasLearnedSaveEvent', true

    it 'should hide the feed', ->
      expect($rootScope.showLearnSaveEventPopover).toBe false

    it 'should optionally show the next step of the walkthrough', ->
      expect(ctrl.optionallyShowWalkthrough).toHaveBeenCalled()
