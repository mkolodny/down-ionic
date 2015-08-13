require 'angular'
require 'angular-mocks'
require 'ng-cordova'
require '../common/auth/auth-module'
require './facebook-sync-module'
FacebookSyncCtrl = require './facebook-sync-controller'

describe 'facebook sync controller', ->
  $cordovaOauth = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  fbClientId = null
  scope = null

  beforeEach angular.mock.module('down.facebookSync')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ngCordova.plugins.oauth')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $cordovaOauth = $injector.get '$cordovaOauth'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    fbClientId = $injector.get 'fbClientId'
    scope = $rootScope.$new()

    ctrl = $controller FacebookSyncCtrl,
      $scope: scope
      $cordovaOauth: $cordovaOauth
      Auth: Auth
  )

  describe 'syncing with facebook', ->
    deferredOAuth = null

    beforeEach ->
      deferredOAuth = $q.defer()
      spyOn($cordovaOauth, 'facebook').and.returnValue deferredOAuth.promise

      ctrl.syncWithFacebook()

    it 'should try to login with Facebook', ->
      permissions = ['email', 'user_friends', 'public_profile']
      expect($cordovaOauth.facebook).toHaveBeenCalledWith fbClientId, permissions

    describe 'when oauth is successful', ->
      deferredSync = null
      accessToken = null

      beforeEach ->
        deferredSync = $q.defer()
        spyOn(Auth, 'syncWithFacebook').and.returnValue deferredSync.promise

        accessToken = 'asdf1234'
        deferredOAuth.resolve {access_token: accessToken}
        scope.$apply()

      it 'should sync the backend', ->
        expect(Auth.syncWithFacebook).toHaveBeenCalledWith accessToken

      describe 'when sync is successful', ->
        user = null

        beforeEach ->
          spyOn $state, 'go'
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
          expect(Auth.user).toBe angular.extend(Auth.user, user)

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
        deferredOAuth.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.error).toBe 'It looks like you declined syncing with Facebook :('
