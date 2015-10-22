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
  Auth = null
  PushNotifications = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.pushNotifications')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()
    PushNotifications = $injector.get 'PushNotifications'
    Auth = $injector.get 'Auth'

    ctrl = $controller RequestPushCtrl,
      $scope: scope
      Auth: Auth
      PushNotifications: PushNotifications
  )

  describe 'requesting push notifications permission', ->

    beforeEach ->
      spyOn PushNotifications, 'register'
      spyOn Auth, 'redirectForAuthState'
      spyOn Auth, 'setFlag'

      ctrl.enablePush()

    it 'should trigger the request notifications prompt', ->
      expect(PushNotifications.register).toHaveBeenCalled()

    it 'should set a flag in local storage', ->
      expect(Auth.setFlag).toHaveBeenCalledWith 'hasRequestedPushNotifications', true

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()
