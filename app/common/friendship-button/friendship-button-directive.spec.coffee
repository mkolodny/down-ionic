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
  userId = null

  beforeEach angular.mock.module('down.friendshipButton')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module(($provide) ->
    # Mock a logged in user.
    Auth =
      user:
        id: 1
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    Friendship = $injector.get 'Friendship'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    Auth.isFriend = jasmine.createSpy 'isFriend'

    userId = 1
    element = angular.element """
      <friendship-button user-id="#{userId}">
      """
  )

  describe 'when the user is a friend', ->

    beforeEach ->
      Auth.isFriend.and.returnValue true

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
        spyOn(Friendship, 'deleteWithFriendId').and.returnValue deferred.promise

        anchor = element.find 'a'
        anchor.triggerHandler 'click'

      it 'should show a spinner', ->
        icon = element.find 'i'
        expect(icon).toHaveClass 'fa-spinner'
        expect(icon).toHaveClass 'fa-pulse'

      it 'should delete the friendship', ->
        expect(Friendship.deleteWithFriendId).toHaveBeenCalled()

      describe 'when it\'s removed successfully', ->

        beforeEach ->
          Auth.isFriend.and.returnValue false

          deferred.resolve()
          scope.$apply()

        it 'should show an add friend button', ->
          icon = element.find 'i'
          expect(icon).toHaveClass 'fa-plus-square-o'


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
        icon = element.find 'i'
        expect(icon).toHaveClass 'fa-spinner'
        expect(icon).toHaveClass 'fa-pulse'

      it 'should create a friendship', ->
        friendship =
          userId: Auth.user.id
          friendId: userId
        expect(Friendship.save).toHaveBeenCalledWith friendship

      describe 'when it\'s added successfully', ->

        beforeEach ->
          Auth.isFriend.and.returnValue true

          deferred.resolve()
          scope.$apply()

        it 'should show a remove friend button', ->
          icon = element.find 'i'
          expect(icon).toHaveClass 'fa-check-square'


      describe 'when the add fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should show an add friend button', ->
          icon = element.find 'i'
          expect(icon).toHaveClass 'fa-plus-square-o'
