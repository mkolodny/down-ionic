require 'angular'
require 'angular-mocks'
require '../common/auth/auth-module'
require '../common/resources/resources-module'
AddFromFacebookCtrl = require './add-from-facebook-controller'

describe 'add from facebook controller', ->
  $controller = null
  $q = null
  Auth = null
  ctrl = null
  deferred = null
  friend = null
  scope = null

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    scope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    Auth = $injector.get 'Auth'

    # Mock facebook friends that were saved in local storage.
    friend =
      id: 1
      email: 'aturing@gmail.com'
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535
    Auth.user.facebookFriends = {}
    Auth.user.facebookFriends[friend.id] = friend

    ctrl = $controller AddFromFacebookCtrl,
      $scope: scope
      Auth: Auth
  )

  it 'should set the user\'s facebook friends on the controller', ->
    items = [
      isDivider: true
      title: 'A'
    ,
      isDivider: false
      user: friend
    ]
    expect(ctrl.items).toEqual items

  describe 'pulling to refresh', ->
    deferred = null
    refreshComplete = null

    beforeEach ->
      # Reset the facebook friends saved on the controller.
      ctrl.facebookFriends = []

      # Listen to the refresh complete event to check whether we've broadcasted
      # the event.
      refreshComplete = false
      scope.$on 'scroll.refreshComplete', ->
        refreshComplete = true

      deferred = $q.defer()
      spyOn(Auth, 'getFacebookFriends').and.returnValue {$promise: deferred.promise}
      spyOn ctrl, 'showFacebookFriends'

      ctrl.refresh()

    it 'should fetch the user\'s facebook friends', ->
      expect(Auth.getFacebookFriends).toHaveBeenCalled()

    describe 'when the request succeeds', ->
      newFacebookFriends = null

      beforeEach ->
        userId = 3
        Auth.user.facebookFriends[userId] =
          id: userId
          email: 'jclarke@gmail.com'
          name: 'Joan Clarke'
          username: 'jnasty'
          imageUrl: 'https://facebook.com/profile-pics/jnasty'
          location:
            lat: 40.7265834 # just under 5 mi away
            long: -73.9821535
        deferred.resolve Auth.user.facebookFriends
        scope.$apply()

      it 'should show the facebookFriends', ->
        expect(ctrl.showFacebookFriends).toHaveBeenCalledWith \
            Auth.user.facebookFriends

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true

      it 'should clear a load error', ->
        expect(ctrl.loadError).toBe false

      it 'should clear the loading indicator', ->
        expect(ctrl.isLoading).toBe false


    describe 'when the request fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true

      it 'should show a load error', ->
        expect(ctrl.loadError).toBe true

      it 'should clear the loading indicator', ->
        expect(ctrl.isLoading).toBe false


  describe 'when the user\'s facebook friends haven\'t been saved yet', ->
    facebookFriends = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Auth, 'getFacebookFriends').and.returnValue {$promise: deferred.promise}

      # Mock the user's facebook friends not being set.
      facebookFriends = Auth.user.facebookFriends
      delete Auth.user.facebookFriends

      ctrl = $controller AddFromFacebookCtrl,
        $scope: scope
        Auth: Auth

    it 'should show the loading spinner', ->
      expect(ctrl.isLoading).toBe true

    it 'should request the user\'s facebook friends', ->
      expect(Auth.getFacebookFriends).toHaveBeenCalled()

    describe 'when the fetch succeeds', ->

      beforeEach ->
        spyOn ctrl, 'showFacebookFriends'

        deferred.resolve facebookFriends
        scope.$apply()

      it 'should show the friends', ->
        expect(ctrl.showFacebookFriends).toHaveBeenCalledWith facebookFriends

      it 'should hide the loading spinner', ->
        expect(ctrl.isLoading).toBe false


    describe 'when the fetch fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.loadError).toBe true

      it 'should hide the loading spinner', ->
        expect(ctrl.isLoading).toBe false
