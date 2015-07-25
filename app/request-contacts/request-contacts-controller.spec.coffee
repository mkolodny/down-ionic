require 'angular'
require 'angular-mocks'
require 'ng-cordova'
RequestContactsCtrl = require './request-contacts-controller'

describe 'request contacts controller', ->
  $state = null
  scope = null
  ctrl = null
  localStorage = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    localStorage = $injector.get 'localStorageService'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()
    Auth = angular.copy $injector.get('Auth')

    ctrl = $controller RequestContactsCtrl,
      $scope: scope
      Auth: Auth
  )

  describe 'request contacts permission', ->

    it 'should set localStorage.hasRequestedContacts to true', ->

    describe 'permission granted', ->

      it 'should format the contacts', ->

      it 'should store the formatted contacts in sql lite?', ->

      it 'should send the user to the find friends view', ->

    describe 'permission denied', ->

      it 'should display an error', ->
# ContactError.PERMISSION_DENIED_ERROR