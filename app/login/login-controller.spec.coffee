require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require '../common/auth/auth-module'
LoginCtrl = require './login-controller'

describe 'login controller', ->
  $httpBackend = null
  $ionicLoading = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $httpBackend = $injector.get '$httpBackend'
    $ionicLoading = $injector.get '$ionicLoading'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'

    ctrl = $controller LoginCtrl,
      Auth: Auth
      $scope: scope
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'submitting the login form', ->
    deferred = null

    beforeEach ->
      spyOn ctrl, 'validate'
      deferred = $q.defer()
      spyOn(Auth, 'sendVerificationText').and.returnValue deferred.promise

      ctrl.login()

    it 'should validate the form', ->
      expect(ctrl.validate).toHaveBeenCalled()

    describe 'when the form validates', ->

      beforeEach ->
        # Mock a completed form.
        ctrl.phone = '+1234567890'

        spyOn $ionicLoading, 'show'
        spyOn $ionicLoading, 'hide'
        ctrl.validate.and.returnValue true

        ctrl.login()

      it 'should set phone on auth', ->
        expect(Auth.phone).toEqual ctrl.phone

      it 'should send a verification text', ->
        expect(Auth.sendVerificationText).toHaveBeenCalledWith ctrl.phone

      it 'should show a loading overlay', ->
        template = '''
          <div class="loading-text">Sending you a verification text...</div>
          <ion-spinner icon="bubbles"></ion-spinner>
          '''
        expect($ionicLoading.show).toHaveBeenCalledWith template: template

      describe 'when the request succeeds', ->

        beforeEach ->
          spyOn Auth, 'redirectForAuthState'

          deferred.resolve()
          scope.$apply()

        it 'should go to the verify phone view', ->
          expect(Auth.redirectForAuthState).toHaveBeenCalled()

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


      describe 'when the request fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'For some reason, that didn\'t work'

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


  describe 'validating the login form', ->

    describe 'when the form is valid', ->
      result = null

      beforeEach ->
        scope.loginForm = $valid: true

        result = ctrl.validate()

      it 'should return true', ->
        expect(result).toBe true


    describe 'when the form is invalid', ->
      result = null

      beforeEach ->
        scope.loginForm = $valid: false

        result = ctrl.validate()

      it 'should return true', ->
        expect(result).toBe false
