require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'angular-local-storage'
require '../common/auth/auth-module'
FindFriendsCtrl = require './find-friends-controller'

xdescribe 'find friends controller', ->
  $q = null
  $state = null
  Auth = null
  ctrl = null
  deferred = null
  scope = null
  User = null
  localStorage = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    scope = $rootScope.$new true
    User = $injector.get 'User'
    localStorage = $injector.get 'localStorageService'

    deferred = $q.defer()
    spyOn(User, 'getFacebookFriends').and.returnValue {$promise: deferred.promise}

    ctrl = $controller FindFriendsCtrl,
      Auth: Auth
      $scope: scope
  )

  it 'should request the user\'s facebook friends', ->
    expect(User.getFacebookFriends).toHaveBeenCalled()

  describe 'when the facebook friends request returns', ->

    describe 'successfully', ->
      friend = null

      beforeEach ->
        friend = new User
          id: 1
          name: 'Alan Turing'
          username: 'tdog'
          imageUrl: 'https://graph.facebook.com/2.2/1598714293871/picture'
        deferred.resolve [friend]
        scope.$apply()

      it 'should set the friends on Auth', ->
        # TODO: Remove this.
        friends = {}
        friends[friend.id] = friend
        expect(Auth.friends).toEqual friends

      it 'should generate the items list', ->
        items = [
          isDivider: true
          title: 'Friends Using Down'
        ,
          isDivider: false
          id: friend.id
          name: friend.name
          username: friend.username
          imageUrl: friend.imageUrl
        ,
          isDivider: true
          title: 'Contacts'
        ]
        expect(ctrl.items).toEqual items


    describe 'with an error', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.fbFriendsRequestError).toBe true


  describe 'when the user finishes', ->

    beforeEach ->
      spyOn Auth, 'redirectForAuthState'
      localStorage.set 'hasCompletedFindFriends', false

      ctrl.done()

    afterEach ->
      localStorage.clearAll()

    it 'should set localStorage.hasCompletedFindFriends', ->
      expect(localStorage.get('hasCompletedFindFriends')).toBe true

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()
