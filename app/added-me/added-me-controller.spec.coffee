require 'angular'
require 'angular-mocks'
AddedMeCtrl = require './added-me-controller'

describe 'AddedMe controller', ->
  $q = null
  Auth = null
  ctrl = null
  Friendship = null
  scope = null

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    Friendship = $injector.get 'Friendship'
    scope = $injector.get '$rootScope'

    ctrl = $controller AddedMeCtrl,
      $scope: scope
      Auth: Auth
  )

  describe 'on enter', ->

    beforeEach ->
      spyOn ctrl, 'refresh'

      scope.$emit '$ionicView.enter'
      scope.$apply()

    it 'should refresh the view', ->
      expect(ctrl.refresh).toHaveBeenCalled()

    it 'should set a loading flag', ->
      expect(ctrl.isLoading).toBe true


  describe 'refreshing', ->
    deferred = null
    refreshComplete = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Auth, 'getAddedMe').and.returnValue {$promise: deferred.promise}

      # Listen to the refresh complete event to check whether we've broadcasted
      # the event.
      refreshComplete = false
      scope.$on 'scroll.refreshComplete', ->
        refreshComplete = true

      ctrl.refresh()

    it 'should request the users who added the current user', ->
      expect(Auth.getAddedMe).toHaveBeenCalled()

    describe 'when the added me request succeeds', ->
      addedMe = null

      beforeEach ->
        addedMe = [
          id: 2
          email: 'alovelace@gmail.com'
          name: 'Ada Lovelace'
          username: 'lovelace'
          imageUrl: 'https://facebook.com/profile-pics/lovalace'
          location:
            lat: 40.7265834
            long: -73.9821535
        ]
        deferred.resolve addedMe
        scope.$apply()

      it 'should set the users on the controller', ->
        expect(ctrl.users).toBe addedMe

      it 'should unset a loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true


    describe 'when the added me request fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.error).toBe 'Sorry, we weren\'t able to reach the server.'

      it 'should unset a loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true

      describe 'trying again', ->

        beforeEach ->
          ctrl.refresh()

        it 'should clear the error', ->
          expect(ctrl.error).toBeNull()


  describe 'deleting someone who added you', ->
    user = null

    beforeEach ->
      user =
        id: 2
        email: 'alovelace@gmail.com'
        name: 'Ada Lovelace'
        username: 'lovelace'
        imageUrl: 'https://facebook.com/profile-pics/lovalace'
        location:
          lat: 40.7265834
          long: -73.9821535
      ctrl.users = [user]
      spyOn Friendship, 'ack'

      ctrl.delete user

    it 'should remove the user from the array of users', ->
      expect(ctrl.users).toEqual []

    it 'should update the friendship', ->
      expect(Friendship.ack).toHaveBeenCalledWith {friend: user.id}
