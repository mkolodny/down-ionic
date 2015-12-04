require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
MyEventsCtrl = require './my-events-controller'

describe 'my events controller', ->
  $q = null
  $state = null
  $stateParams = null
  Auth = null
  ctrl = null
  event = null
  scope = null
  ngToast = null
  $meteor = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('ngToast')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $stateParams = angular.copy $injector.get('$stateParams')
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'
    ngToast = $injector.get 'ngToast'
    $meteor = $injector.get '$meteor'

    # Mock the current user.
    Auth.user =
      id: 1
      name: 'Andrew Linfoot'
      firstName: 'Andrew'
      lastName: 'Linfoot'
      imageUrl: 'http://someimageurl.com'

    ctrl = $controller MyEventsCtrl,
      $scope: scope
      $stateParams: $stateParams
  )

  it 'should init the items', ->
    expect(ctrl.items).toEqual []

  it 'should set the current user on the controller', ->
    expect(ctrl.currentUser).toBe Auth.user

  ##$ionicView.loaded
  describe 'when the view is loaded', ->

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
        ctrl.commentsCountLoaded = true

        ctrl.handleLoadedData()

      it 'should clear the loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should stop the ion-refresher', ->
        expect(scope.$broadcast).toHaveBeenCalledWith 'scroll.refreshComplete'

      it 'should build the items', ->
        expect(ctrl.buildItems).toHaveBeenCalled()

      it 'should set the items on the controller', ->
        expect(ctrl.items).toBe items


  ##refresh
  describe 'pull to refresh', ->

    beforeEach ->
      ctrl.savedEventsLoaded = true
      ctrl.commentsCountLoaded = true

      spyOn ctrl, 'getSavedEvents'

      ctrl.refresh()

    it 'should clear the loaded flags', ->
      expect(ctrl.savedEventsLoaded).toBe undefined
      expect(ctrl.commentsCountLoaded).toBe undefined

    it 'should get the events', ->
      expect(ctrl.getSavedEvents).toHaveBeenCalled()


  ##buildItems
  describe 'building the items', ->
    savedEvent = null

    beforeEach ->
      savedEvent =
        id: 1
        eventId: 2
        userId: 1
      ctrl.commentsCount =
        '2': 1
      ctrl.savedEvents = [savedEvent]

    it 'should build the items', ->
      expectedItems = [
        savedEvent: savedEvent
        commentsCount: 1
      ]
      expect(ctrl.buildItems()).toEqual expectedItems


  ##getSavedEvents
  describe 'getting a users saved events', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()

      spyOn(Auth, 'getSavedEvents').and.returnValue {$promise: deferred.promise}
      spyOn(scope, '$broadcast').and.callThrough()

      ctrl.getSavedEvents()

    it 'should get the saved events', ->
      expect(Auth.getSavedEvents).toHaveBeenCalled()

    describe 'successfully', ->
      savedEvents = null

      beforeEach ->
        spyOn ctrl, 'handleLoadedData'
        spyOn ctrl, 'getCommentsCount'
        savedEvents = 'savedEvents'

        deferred.resolve savedEvents
        scope.$apply()

      it 'should set the saved events on the controller', ->
        expect(ctrl.savedEvents).toBe savedEvents

      it 'should set the saved events loaded flag', ->
        expect(ctrl.savedEventsLoaded).toBe true

      it 'should handle the loaded data', ->
        expect(ctrl.handleLoadedData).toHaveBeenCalled()

      it 'should get the comment count', ->
        expect(ctrl.getCommentsCount).toHaveBeenCalled()


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'
        deferred.reject()
        scope.$apply()

      it 'should throw an error', ->
        expect(ngToast.create).toHaveBeenCalled()


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
