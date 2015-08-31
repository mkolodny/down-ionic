require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require '../common/resources/resources-module'
SetUsernameCtrl = require './set-username-controller'

describe 'set username controller', ->
  $ionicLoading = null
  $q = null
  $state = null
  ctrl = null
  Auth = null
  scope = null
  User = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicLoading = $injector.get '$ionicLoading'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    scope = $rootScope.$new()
    User = $injector.get 'User'

    ctrl = $controller SetUsernameCtrl,
      Auth: Auth
      $scope: scope
  )

  describe 'setting a username', ->
    deferred = null

    beforeEach ->
      spyOn ctrl, 'validate'
      deferred = $q.defer()
      spyOn(User, 'update').and.returnValue {$promise: deferred.promise}

      ctrl.setUsername()

    it 'should validate the form', ->
      expect(ctrl.validate).toHaveBeenCalled()

    describe 'when the form validates', ->
      user = null

      beforeEach ->
        ctrl.validate.and.returnValue true
        spyOn $ionicLoading, 'show'
        spyOn $ionicLoading, 'hide'
        Auth.user =
          id: 1
          name: 'Alan Turing'
          email: 'aturing@gmail.com'
          imageUrl: 'http://facebook.com/profile-pic/tdog'
        user = angular.extend {username: ctrl.username}, Auth.user

        ctrl.setUsername()

      it 'should show the loading overlay', ->
        template = '''
          <div class="loading-text">Saving...</div>
          <ion-spinner icon="bubbles"></ion-spinner>
          '''
        expect($ionicLoading.show).toHaveBeenCalledWith {template: template}

      it 'should update the user', ->
        expect(User.update).toHaveBeenCalledWith user

      describe 'when the update succeeds', ->

        beforeEach ->
          spyOn Auth, 'redirectForAuthState'
          spyOn Auth, 'setUser'

          deferred.resolve user
          scope.$apply()

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'should set the user on Auth', ->
          expect(Auth.setUser).toHaveBeenCalledWith user

        it 'should redirect for auth state', ->
          expect(Auth.redirectForAuthState).toHaveBeenCalled()


      describe 'when the update fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'For some reason, that didn\'t work.'


  describe 'validating the set username form', ->

    describe 'when the form is valid', ->
      result = null

      beforeEach ->
        scope.setUsernameForm = $valid: true

        result = ctrl.validate()

      it 'should return true', ->
        expect(result).toBe true


    describe 'when the form is invalid', ->
      result = null

      beforeEach ->
        scope.setUsernameForm = $valid: false

        result = ctrl.validate()

      it 'should return false', ->
        expect(result).toBe false


  ###
  describe 'checking whether a username is available', ->
    deferred = null

    beforeEach ->
      ctrl.username = 'tdog'
      deferred = $q.defer()
      spyOn(User, 'isUsernameAvailable').and.returnValue deferred.promise

      ctrl.isUsernameAvailable()

    it 'should check on the server', ->
      expect(User.isUsernameAvailable).toHaveBeenCalledWith ctrl.username

    describe 'when the request succeeds', ->
      isUsernameAvailable = null

      beforeEach ->
        isUsernameAvailable = true
        deferred.resolve isUsernameAvailable
        scope.$apply()
  ###
