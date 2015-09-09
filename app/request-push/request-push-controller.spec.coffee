require 'angular'
require 'angular-mocks'
require 'angular-local-storage'
require 'ng-cordova'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
RequestPushCtrl = require './request-push-controller'

describe 'request push controller', ->
  $cordovaPush = null
  $cordovaDevice = null
  $state = null
  $q = null
  scope = null
  APNSDevice = null
  ctrl = null
  localStorage = null
  Auth = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('ngCordova.plugins.push')

  beforeEach angular.mock.module('ngCordova.plugins.device')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $cordovaPush = $injector.get '$cordovaPush'
    $cordovaDevice = $injector.get '$cordovaDevice'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $q = $injector.get '$q'
    scope = $rootScope.$new()
    localStorage = $injector.get 'localStorageService'
    APNSDevice = $injector.get 'APNSDevice'
    Auth = $injector.get 'Auth'

    ctrl = $controller RequestPushCtrl,
      $scope: scope
      Auth: Auth
  )

  afterEach ->
    localStorage.clearAll()

  describe 'requesting push notifications permission', ->
    deferred = null
    apnsDeferred = null
    iosConfig = null
    device = null

    beforeEach ->
      deferred = $q.defer()
      spyOn($cordovaPush, 'register').and.returnValue deferred.promise

      spyOn Auth, 'redirectForAuthState'

      iosConfig =
        badge: true
        sound: true
        alert: true

      ctrl.enablePush()

    it 'should trigger the request notifications prompt', ->
      expect($cordovaPush.register).toHaveBeenCalledWith iosConfig

    it 'should set a flag in local storage', ->
      expect(localStorage.get 'hasRequestedPushNotifications').toBe true

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()

    describe 'permission granted', ->
      deviceToken = null

      beforeEach ->
        deviceToken = '1234'

        spyOn ctrl, 'saveToken'

        deferred.resolve deviceToken
        scope.$apply()

      it 'should call save token', ->
        expect(ctrl.saveToken).toHaveBeenCalledWith deviceToken


  describe 'saving the device token', ->
    device = null
    deviceToken = null

    beforeEach ->
      deviceToken = '1234'
      Auth.user =
        id: 1

      device =
        cordova: '5.0'
        model: 'iPhone 8'
        platform: 'iOS'
        uuid: '1234'
        version: '8.1'
      spyOn($cordovaDevice, 'getDevice').and.returnValue device

      spyOn APNSDevice, 'save'

      ctrl.saveToken deviceToken

    it 'should create a new APNSDevice and call save', ->
      name = device.model + ', ' + device.version
      apnsDevice =
        userId: Auth.user.id
        registrationId: deviceToken
        deviceId: device.uuid
        name: name
      expect(APNSDevice.save).toHaveBeenCalledWith apnsDevice
