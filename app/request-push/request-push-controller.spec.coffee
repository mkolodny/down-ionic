require 'angular'
require 'angular-mocks'
require 'angular-local-storage'
require 'ng-cordova'
require '../common/auth/auth-module'
require '../common/push-notifications/push-notifications-module'
RequestPushCtrl = require './request-push-controller'

describe 'request push controller', ->
  $state = null
  $q = null
  scope = null
  ctrl = null
  localStorage = null
  Auth = null
  PushNotifications = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.pushNotifications')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()
    localStorage = $injector.get 'localStorageService'
    PushNotifications = $injector.get 'PushNotifications'
    Auth = $injector.get 'Auth'

    ctrl = $controller RequestPushCtrl,
      $scope: scope
      Auth: Auth
      PushNotifications: PushNotifications
  )

  afterEach ->
    localStorage.clearAll()

  describe 'requesting push notifications permission', ->
    
    beforeEach ->
      spyOn PushNotifications, 'register'
      spyOn Auth, 'redirectForAuthState'

      ctrl.enablePush()

    it 'should trigger the request notifications prompt', ->
      expect(PushNotifications.register).toHaveBeenCalled()

    it 'should set a flag in local storage', ->
      expect(localStorage.get 'hasRequestedPushNotifications').toBe true

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()
