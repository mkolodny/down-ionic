require 'angular'
require 'angular-mocks'
RequestContactsCtrl = require './request-contacts-controller'

describe 'request contacts controller', ->
  $state = null
  $q = null
  Auth = null
  scope = null
  ctrl = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()
    Auth = angular.copy $injector.get('Auth')

    ctrl = $controller RequestContactsCtrl,
      $scope: scope
      Auth: Auth
  )

  describe 'tapping continue', ->

    beforeEach ->
      spyOn Auth, 'redirectForAuthState'

      ctrl.requestContacts()

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()
