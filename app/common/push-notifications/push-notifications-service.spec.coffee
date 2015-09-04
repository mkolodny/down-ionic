require 'angular-mocks'
require 'angular-local-storage'
require 'ng-cordova'
require './push-notifications-module'
require '../resources/resources-module'
require '../auth/auth-module'

fdescribe 'PushNotifications service', ->
  $cordovaPush = null
  $cordovaDevice = null
  $q = null
  localStorage = null
  scope = null
  APNSDevice = null
  Auth = null
  PushNotifications = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.pushNotifications')

  beforeEach angular.mock.module('ngCordova.plugins.push')

  beforeEach angular.mock.module('ngCordova.plugins.device')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module(($provide) ->
    $cordovaPush =
      register: jasmine.createSpy '$cordovaPush.register'
    $provide.value '$cordovaPush', $cordovaPush

    $cordovaDevice =
      getDevice: jasmine.createSpy '$cordovaDevice.getDevice'
    $provide.value '$cordovaDevice', $cordovaDevice

    Auth =
      user:
        id: 1
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    scope = $rootScope.$new()
    APNSDevice = $injector.get 'APNSDevice'
    localStorage = $injector.get 'localStorageService'
    PushNotifications = angular.copy $injector.get('PushNotifications')
  )

  afterEach ->
    localStorage.clearAll()

  describe 'registering a device', ->
    deferred = null
    apnsDeferred = null
    iosConfig = null
    device = null

    beforeEach ->
      deferred = $q.defer()
      $cordovaPush.register.and.returnValue deferred.promise

      iosConfig =
        badge: true
        sound: true
        alert: true

      PushNotifications.register()


    it 'should trigger the request notifications prompt', ->
      expect($cordovaPush.register).toHaveBeenCalledWith iosConfig

    describe 'permission granted', ->
      deviceToken = null

      beforeEach ->
        deviceToken = '1234'

        spyOn PushNotifications, 'saveToken'

        deferred.resolve deviceToken
        scope.$apply()

      it 'should call save token', ->
        expect(PushNotifications.saveToken).toHaveBeenCalledWith deviceToken


    describe 'permission denied', ->
      beforeEach ->
        spyOn Auth, 'redirectForAuthState'

        deferred.reject()
        scope.$apply()


  describe 'saving the device token', ->
    device = null
    deviceToken = null
    deferred = null
    resolved = null
    rejected = null

    beforeEach ->
      deviceToken = '1234'

      device =
        cordova: '5.0'
        model: 'iPhone 8'
        platform: 'iOS'
        uuid: '1234'
        version: '8.1'
      $cordovaDevice.getDevice.and.returnValue device

      deferred = $q.defer()
      spyOn(APNSDevice, 'save').and.returnValue {$promise: deferred.promise}

      PushNotifications.saveToken(deviceToken).then ->
        resolved = true
      , ->
        rejected = true

    it 'should create a new APNSDevice and call save', ->
      name = device.model + ', ' + device.version
      apnsDevice =
        userId: Auth.user.id
        registrationId: deviceToken
        deviceId: device.uuid
        name: name
      expect(APNSDevice.save).toHaveBeenCalledWith apnsDevice

    describe 'successfully', ->

      beforeEach ->
        deferred.resolve()
        scope.$apply()

      it 'should resolve the promise', ->
        expect(resolved).toBe true

    describe 'save failed', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should reject the promise', ->
        expect(rejected).toBe true
