require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
VerifyPhoneCtrl = require './verify-phone-controller'

describe 'verify phone controller', ->
  ctrl = null
  Auth = null
  User = null
  $q = null
  $state = null
  $rootScope = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $rootScope = $injector.get '$rootScope'
    Auth = angular.copy $injector.get('Auth')
    User = $injector.get 'User'

    Auth.phone = '+15555555555'

    ctrl = $controller VerifyPhoneCtrl,
      Auth: Auth
  )

  describe 'when form is submitted', ->
    deferred = null
    promise = null

    beforeEach ->
      ctrl.code = '1234'
      deferred = $q.defer()
      promise = deferred.promise
      spyOn(Auth, 'authenticate').and.returnValue promise
      ctrl.authenticate()

    it 'should call Auth.authenticate with phone and code', ->
      expect(Auth.authenticate).toHaveBeenCalledWith Auth.phone, ctrl.code

    describe 'when authentication is successful', ->
      user = null

      beforeEach ->
        spyOn $state, 'go'

      describe 'when the user doesn\'t have an email', ->

        beforeEach ->
          user =
            id: 1
          deferred.resolve user
          $rootScope.$apply()

        it 'should go to the sync with facebook view', ->
          expect($state.go).toHaveBeenCalledWith 'down.syncWithFacebook'

      describe 'the user doesn\'t have a username', ->
      
        it 'should go to the add username view', ->