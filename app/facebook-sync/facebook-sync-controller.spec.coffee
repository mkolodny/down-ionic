require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require '../ionic/ionic-angular.js'
require 'ng-cordova'
require '../common/auth/auth-module'
require './facebook-sync-module'
FacebookSyncCtrl = require './facebook-sync-controller'

describe 'facebook sync controller', ->
  $cordovaFacebook = null
  $httpBackend = null
  $ionicLoading = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.facebookSync')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ngCordova')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $cordovaFacebook = $injector.get '$cordovaFacebook'
    $httpBackend = $injector.get '$httpBackend'
    $ionicLoading = $injector.get '$ionicLoading'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    scope = $rootScope.$new()

    # This is necessary because for some reason ionic is requesting this file
    # when the promise gets resolved.
    # TODO: Figure out why, and remove this.
    $httpBackend.whenGET 'app/facebook-sync/facebook-sync.html'
      .respond ''

    ctrl = $controller FacebookSyncCtrl,
      $scope: scope
      Auth: Auth
  )

  describe 'syncing with facebook', ->
    deferredFacebook = null

    beforeEach ->
      deferredFacebook = $q.defer()
      spyOn($cordovaFacebook, 'login').and.returnValue deferredFacebook.promise

      ctrl.facebookSync()

    it 'should try to login with Facebook', ->
      permissions = ['email', 'user_friends', 'public_profile']
      expect($cordovaFacebook.login).toHaveBeenCalledWith permissions

    describe 'when login is successful', ->
      deferredSync = null
      accessToken = null

      beforeEach ->
        spyOn $ionicLoading, 'show'
        spyOn $ionicLoading, 'hide'
        deferredSync = $q.defer()
        spyOn(Auth, 'facebookSync').and.returnValue deferredSync.promise

        accessToken = 'asdf1234'
        deferredFacebook.resolve
          authResponse:
            accessToken: accessToken
        scope.$apply()

      it 'should show the loading overlay', ->
        template = '''
          <div class="loading-text">Syncing...</div>
          <ion-spinner icon="bubbles"></ion-spinner>
          '''
        expect($ionicLoading.show).toHaveBeenCalledWith {template: template}

      it 'should sync the backend', ->
        expect(Auth.facebookSync).toHaveBeenCalledWith accessToken

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

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


      describe 'when sync fails', ->

        beforeEach ->
          deferredSync.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'Oops, something went wrong. Please try again.'

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


    describe 'when oauth fails', ->

      beforeEach ->
        deferredFacebook.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.error).toBe 'Oops, something went wrong. Please try again.'
