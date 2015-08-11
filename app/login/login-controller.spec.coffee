require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
LoginCtrl = require './login-controller'

describe 'login controller', ->
  $httpBackend = null
  $rootScope = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $httpBackend = $injector.get '$httpBackend'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    scope = $rootScope.$new true

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

        ctrl.validate.and.returnValue true
        spyOn Auth, 'redirectForAuthState'

        ctrl.login()

      it 'should set phone on auth', ->
        expect(Auth.phone).toEqual ctrl.phone

      it 'should send a verification text', ->
        expect(Auth.sendVerificationText).toHaveBeenCalledWith ctrl.phone

      describe 'when the request succeeds', ->

        beforeEach ->
          deferred.resolve()
          $rootScope.$apply()

        it 'should go to the verify phone view', ->
          expect(Auth.redirectForAuthState).toHaveBeenCalled()


      describe 'when the request fails', ->

        beforeEach ->
          deferred.reject()
          $rootScope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'For some reason, that didn\'t work'


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
