require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../common/auth/auth-module'
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

  ##$ionicView.loaded
  describe 'when the view is loaded', ->

    beforeEach ->
      spyOn ctrl, 'getSavedEvents'

      scope.$emit '$ionicView.loaded'
      scope.$apply()

    it 'should get the saved events', ->
      expect(ctrl.getSavedEvents).toHaveBeenCalled()


  ##getSavedEvents
  describe 'getting a users saved events', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()

      spyOn(Auth, 'getSavedEvents').and.returnValue {$promise: deferred.promise}

      ctrl.getSavedEvents()

    it 'should get the saved events', ->
      expect(Auth.getSavedEvents).toHaveBeenCalled()

    it 'should set a loading flag', ->
      expect(ctrl.isLoading).toBe true

    describe 'successfully', ->
      items = null
      savedEvents = null

      beforeEach ->
        items = []
        spyOn(ctrl, 'buildItems').and.returnValue items
        savedEvents = 'savedEvents'

        spyOn scope, '$broadcast'

        deferred.resolve savedEvents
        scope.$apply()

      it 'should set the saved events on the controller', ->
        expect(ctrl.savedEvents).toBe savedEvents

      it 'should build the items', ->
        expect(ctrl.buildItems).toHaveBeenCalled()

      it 'should set the items on the controller', ->
        expect(ctrl.items).toBe items

      it 'should stop the ion-refresher', ->
        expect(scope.$broadcast).toHaveBeenCalledWith 'scroll.refreshComplete'


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'
        deferred.reject()
        scope.$apply()

      it 'should throw an error', ->
        expect(ngToast.create).toHaveBeenCalled()

      it 'should stop the ion-refresher', ->
        expect(scope.$broadcast).toHaveBeenCalledWith 'scroll.refreshComplete'


  ##buildItems
  describe 'building the items', ->
    savedEvent = null

    beforeEach ->
      savedEvent =
        id: 1
        eventId: 2
        userId: 1

      ctrl.savedEvents = [savedEvent]

    it 'should build the items', ->
      expectedItems = [
        savedEvent: savedEvent
      ]
      expect(ctrl.buildItems()).toEqual expectedItems
