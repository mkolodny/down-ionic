require 'angular'
require 'angular-mocks'
require 'ng-cordova'
require '../common/auth/auth-module'
require './facebook-sync-module'
FacebookSyncCtrl = require './facebook-sync-controller'

describe 'facebook sync controller', ->
  $cordovaFacebook = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('down.facebookSync')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ngCordova')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $cordovaFacebook = $injector.get '$cordovaFacebook'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    scope = $rootScope.$new()

    ctrl = $controller FacebookSyncCtrl,
      $scope: scope
      Auth: Auth
  )

  describe 'syncing with facebook', ->
    deferredFacebook = null

    beforeEach ->
      deferredFacebook = $q.defer()
      spyOn($cordovaFacebook, 'login').and.returnValue deferredFacebook.promise

      ctrl.syncWithFacebook()

    it 'should try to login with Facebook', ->
      permissions = ['email', 'user_friends', 'public_profile']
      expect($cordovaFacebook.login).toHaveBeenCalledWith permissions

    describe 'when login is successful', ->
      deferredSync = null
      accessToken = null

      beforeEach ->
        deferredSync = $q.defer()
        spyOn(Auth, 'syncWithFacebook').and.returnValue deferredSync.promise

        accessToken = 'asdf1234'
        deferredFacebook.resolve
          authResponse:
            accessToken: accessToken
        scope.$apply()

      it 'should sync the backend', ->
        expect(Auth.syncWithFacebook).toHaveBeenCalledWith accessToken

      describe 'when sync is successful', ->
        user = null

        beforeEach ->
          spyOn $state, 'go'
          spyOn Auth, 'setUser'
          Auth.user =
            friends: 'some friends'
          user =
            id: 1
            name: 'Alan Turing'
            email: 'aturing@gmail.com'
            image_url: 'http://facebook.com/profile-pic/tdog'
          deferredSync.resolve user
          scope.$apply()

        it 'should set the user on Auth', ->
          expect(Auth.setUser).toHaveBeenCalledWith user

        it 'should go to the set username view', ->
          expect($state.go).toHaveBeenCalledWith 'setUsername'


      describe 'when sync fails', ->

        beforeEach ->
          deferredSync.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'Oops, something went wrong. Please try again.'


    describe 'when oauth fails', ->

      beforeEach ->
        deferredFacebook.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.error).toBe 'Oops, something went wrong. Please try again.'
