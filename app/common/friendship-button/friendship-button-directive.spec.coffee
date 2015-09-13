require 'angular'
require 'angular-mocks'
require '../auth/auth-module'
require '../resources/resources-module'
require './friendship-button-module'

describe 'friendship button directive', ->
  $compile = null
  $q = null
  Auth = null
  deferred = null
  element = null
  Friendship = null
  scope = null
  User = null

  beforeEach angular.mock.module('down.friendshipButton')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module(($provide) ->
    # Mock a logged in user.
    Auth =
      user:
        id: 1
      setUser: jasmine.createSpy 'Auth.setUser'
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    scope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    Friendship = $injector.get 'Friendship'
    User = $injector.get 'User'

    Auth.isFriend = jasmine.createSpy 'isFriend'

    scope.friend =
      id: 2
    element = angular.element """
      <friendship-button user="friend">
      """
  )

  describe 'when the user is a friend', ->

    beforeEach ->
      Auth.isFriend.and.returnValue true
      Auth.user.friends = {}
      Auth.user.friends[scope.friend.id] = scope.friend

      $compile(element) scope
      scope.$digest()

    it 'should show a remove friend button', ->
      anchor = element.find 'a'
      icon = element.find 'i'

      expect(anchor.length).toBe 1
      expect(icon.length).toBe 1
      expect(icon).toHaveClass 'fa-check-square'

    describe 'tapping the remove friend button', ->
      deferred = null

      beforeEach ->
        deferred = $q.defer()
        spyOn(Friendship, 'deleteWithFriendId').and.returnValue
          $promise: deferred.promise

        anchor = element.find 'a'
        anchor.triggerHandler 'click'

      it 'should show a spinner', ->
        icon = element.find 'ion-spinner'
        expect(icon.length).toBe 1

      it 'should delete the friendship', ->
        expect(Friendship.deleteWithFriendId).toHaveBeenCalledWith scope.friend.id

      describe 'when it\'s removed successfully', ->

        beforeEach ->
          Auth.isFriend.and.returnValue false

          deferred.resolve()
          scope.$apply()

        it 'should show an add friend button', ->
          icon = element.find 'i'
          expect(icon).toHaveClass 'fa-plus-square-o'

        it 'should remove the friend from the user\'s friends', ->
          expect(Auth.user.friends).toEqual {}

        it 'should set the user on auth', ->
          expect(Auth.setUser).toHaveBeenCalledWith Auth.user


      describe 'when the remove fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should show a remove friend button', ->
          icon = element.find 'i'
          expect(icon).toHaveClass 'fa-check-square'


  describe 'when the user isn\'t a friend yet', ->

    beforeEach ->
      Auth.isFriend.and.returnValue false
      Auth.user.friends = {}

      $compile(element) scope
      scope.$digest()

    it 'should show a remove friend button', ->
      anchor = element.find 'a'
      icon = element.find 'i'

      expect(anchor.length).toBe 1
      expect(icon.length).toBe 1
      expect(icon).toHaveClass 'fa-plus-square-o'

    describe 'tapping the add friend button', ->
      deferred = null

      beforeEach ->
        deferred = $q.defer()
        spyOn(Friendship, 'save').and.returnValue {$promise: deferred.promise}

        anchor = element.find 'a'
        anchor.triggerHandler 'click'

      it 'should show a spinner', ->
        icon = element.find 'ion-spinner'
        expect(icon.length).toBe 1

      it 'should create a friendship', ->
        friendship =
          userId: Auth.user.id
          friendId: scope.friend.id
        expect(Friendship.save).toHaveBeenCalledWith friendship

      describe 'when it\'s added successfully', ->

        beforeEach ->
          Auth.isFriend.and.returnValue true

          deferred.resolve()
          scope.$apply()

        it 'should show a remove friend button', ->
          icon = element.find 'i'
          expect(icon).toHaveClass 'fa-check-square'

        it 'should add the friend to the user\'s friends', ->
          expect(Auth.user.friends[scope.friend.id]).toEqual scope.friend

        it 'should set the user on auth', ->
          expect(Auth.setUser).toHaveBeenCalledWith Auth.user


      describe 'when the add fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should show an add friend button', ->
          icon = element.find 'i'
          expect(icon).toHaveClass 'fa-plus-square-o'
