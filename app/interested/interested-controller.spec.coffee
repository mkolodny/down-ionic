require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../common/auth/auth-module'
InterestedCtrl = require './interested-controller'

describe 'interested controller', ->
  $q = null
  $state = null
  $stateParams = null
  Auth = null
  ctrl = null
  event = null
  Event = null
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
    Event = $injector.get 'Event'
    scope = $injector.get '$rootScope'
    ngToast = $injector.get 'ngToast'

    # Mock the current user.
    Auth.user = 
      id: 1
      name: 'Andrew Linfoot'
      firstName: 'Andrew'
      lastName: 'Linfoot'
      imageUrl: 'http://someimageurl.com'

    event =
      id: 1
      title: 'Bars?!?!'
      datetime: new Date()
      place:
        name: 'B Bar & Grill'
        lat: 40.7270718
        long: -73.9919324
      createdAt: new Date()
    $stateParams.event = event

    ctrl = $controller InterestedCtrl,
      $scope: scope
      $stateParams: $stateParams
  )

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  ##$ionicView.beforeEnter
  describe 'before the view enters', ->

    beforeEach ->
      spyOn ctrl, 'getInterested'

      scope.$emit '$ionicView.beforeEnter'
      scope.$apply()

    it 'should get the interested users', ->
      expect(ctrl.getInterested).toHaveBeenCalled()


  ##getInterested
  describe 'getting the interested users', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Event, 'interested').and.returnValue {$promise: deferred.promise}

      ctrl.getInterested()

    it 'should get the interested users for the event', ->
      expect(Event.interested).toHaveBeenCalledWith event.id

    describe 'successfully', ->
      interestedUsers = null
      items = null

      beforeEach ->
        items = []
        spyOn(ctrl, 'buildItems').and.returnValue items

        interestedUsers = []
        deferred.resolve interestedUsers
        scope.$apply()

      it 'should set the users on the controller', ->
        expect(ctrl.users).toBe interestedUsers

      it 'should build the items', ->
        expect(ctrl.items).toBe items


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ngToast.create).toHaveBeenCalled()


  ##buildItems
  describe 'building the items', ->
    friend = null
    notFriend = null

    beforeEach ->
      friend =
        id: 2
      notFriend =
        id: 3
      Auth.user.friends = {}
      Auth.user.friends[friend.id] = friend
      ctrl.users = [friend, notFriend]

    it 'should build the items', ->
      expectedItems = [
        isDivider: true
        title: 'Friends'
      ,
        isDivider: false
        user: friend
      ,
        isDivider: true
        title: 'Connections'
      ,
        isDivider: false
        user: notFriend
      ]
      expect(ctrl.buildItems()).toEqual expectedItems





