require 'angular'
require 'angular-mocks'
require 'angular-local-storage'
require 'angular-ui-router'
VerifyPhoneCtrl = require './verify-phone-controller'

describe 'verify phone controller', ->
  $q = null
  $rootScope = null
  $state = null
  ctrl = null
  Auth = null
  localStorage = null
  scope = null
  User = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    localStorage = $injector.get 'localStorageService'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    Auth.phone = '+15555555555'

    ctrl = $controller VerifyPhoneCtrl,
      Auth: Auth
      $scope: scope
  )

  afterEach ->
    localStorage.clearAll()

  describe 'when form is submitted', ->
    deferred = null

    beforeEach ->
      spyOn ctrl, 'validate'
      ctrl.code = '1234'
      deferred = $q.defer()
      spyOn(Auth, 'authenticate').and.returnValue deferred.promise

      ctrl.authenticate()

    it 'should validate the form', ->
      expect(ctrl.validate).toHaveBeenCalled()

    describe 'when the form validates', ->

      beforeEach ->
        ctrl.validate.and.returnValue true

        ctrl.authenticate()

      it 'should call Auth.authenticate with phone and code', ->
        expect(Auth.authenticate).toHaveBeenCalledWith Auth.phone, ctrl.code

      describe 'when authentication is successful', ->
        user = null

        beforeEach ->
          spyOn Auth, 'redirectForAuthState'
          deferred.resolve()
          scope.$apply()

        it 'should redirect for auth state', ->
          expect(Auth.redirectForAuthState).toHaveBeenCalled()

      describe 'when authentication fails', ->

        describe 'because the code was incorrect', ->

          beforeEach ->
            deferred.reject 401
            $rootScope.$apply()

          it 'should show an error', ->
            expect(ctrl.error).toBe 'Oops, something went wrong.'


        describe 'because the code was incorrect', ->

          beforeEach ->
            deferred.reject 500
            $rootScope.$apply()

          it 'should show an error', ->
            expect(ctrl.error).toBe 'Looks like you entered the wrong code :('


  describe 'validating the verify phone form', ->

    describe 'when the form is valid', ->
      result = null

      beforeEach ->
        scope.verifyPhoneForm = $valid: true

        result = ctrl.validate()

      it 'should return true', ->
        expect(result).toBe true


    describe 'when the form is invalid', ->
      result = null

      beforeEach ->
        scope.verifyPhoneForm = $valid: false

        result = ctrl.validate()

      it 'should return false', ->
        expect(result).toBe false
