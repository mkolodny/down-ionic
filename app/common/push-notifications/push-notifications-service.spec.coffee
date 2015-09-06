require 'angular-mocks'
require 'angular-local-storage'
require 'angular-animate' # for ngToast
require 'angular-sanitize' # for ngToast
require 'ng-cordova'
require 'ng-toast'
require './push-notifications-module'
require '../resources/resources-module'
require '../auth/auth-module'

describe 'PushNotifications service', ->
  $cordovaPush = null
  $cordovaDevice = null
  $q = null
  localStorage = null
  ngToast = null
  $rootScope = null
  APNSDevice = null
  Auth = null
  GCMDevice = null
  PushNotifications = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.pushNotifications')

  beforeEach angular.mock.module('ngCordova.plugins.push')

  beforeEach angular.mock.module('ngCordova.plugins.device')

  beforeEach angular.mock.module('ngToast')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module(($provide) ->
    $cordovaPush =
      register: jasmine.createSpy '$cordovaPush.register'
    $provide.value '$cordovaPush', $cordovaPush

    $cordovaDevice =
      getDevice: jasmine.createSpy '$cordovaDevice.getDevice'
      getPlatform: jasmine.createSpy '$cordovaDevice.getPlatform'
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
    APNSDevice = $injector.get 'APNSDevice'
    GCMDevice = $injector.get 'GCMDevice'
    localStorage = $injector.get 'localStorageService'
    ngToast = $injector.get 'ngToast'
    PushNotifications = $injector.get 'PushNotifications'
  )

  afterEach ->
    localStorage.clearAll()

  describe 'registering a device', ->
    deferred = null
    apnsDeferred = null
    device = null

    beforeEach ->
      deferred = $q.defer()
      $cordovaPush.register.and.returnValue deferred.promise

    describe 'when it is an Android device', ->
      androidConfig = null
      saveDeferred = null
      resolved = null
      rejected = null

      beforeEach ->
        senderID = '1234'
        PushNotifications.androidSenderID = senderID
        androidConfig =
          senderID: senderID
        $cordovaDevice.getPlatform.and.returnValue 'Android'

        PushNotifications.register().then ->
          resolved = true
        , ->
          rejected = true

      it 'should request the device token', ->
        expect($cordovaPush.register).toHaveBeenCalledWith androidConfig


      describe 'token returned', ->
        deviceToken = null
        saveDeferred = null

        beforeEach ->
          deviceToken = '1234'

          saveDeferred = $q.defer()
          spyOn(PushNotifications, 'saveToken').and.returnValue saveDeferred.promise

          deferred.resolve deviceToken
          $rootScope.$apply()

        it 'should save the token', ->
          expect(PushNotifications.saveToken).toHaveBeenCalledWith deviceToken


        describe 'save succeeds', ->

          beforeEach ->
            saveDeferred.resolve()
            $rootScope.$apply()

          it 'should resolve the promise', ->
            expect(resolved).toBe true


        describe 'save fails', ->

          beforeEach ->
            saveDeferred.reject()
            $rootScope.$apply()

          it 'should reject the promise', ->
            expect(rejected).toBe true


    describe 'when is is an iOS device', ->
      iosConfig = null
      resolved = null
      rejected = null

      beforeEach ->
        iosConfig =
          badge: true
          sound: true
          alert: true
        $cordovaDevice.getPlatform.and.returnValue 'iOS'

        PushNotifications.register().then ->
          resolved = true
        , ->
          rejected = true

      it 'should trigger the request notifications prompt', ->
        expect($cordovaPush.register).toHaveBeenCalledWith iosConfig

      describe 'permission granted', ->
        deviceToken = null
        saveDeferred = null

        beforeEach ->
          deviceToken = '1234'

          saveDeferred = $q.defer()
          spyOn(PushNotifications, 'saveToken').and.returnValue saveDeferred.promise

          deferred.resolve deviceToken
          $rootScope.$apply()

        it 'should call save token', ->
          expect(PushNotifications.saveToken).toHaveBeenCalledWith deviceToken


        describe 'save succeeds', ->

          beforeEach ->
            saveDeferred.resolve()
            $rootScope.$apply()

          it 'should resolve the promise', ->
            expect(resolved).toBe true


        describe 'save fails', ->

          beforeEach ->
            saveDeferred.reject()
            $rootScope.$apply()

          it 'should reject the promise', ->
            expect(rejected).toBe true


      describe 'permission denied', ->
        rejected = null

        beforeEach ->
          deferred.reject()
          $rootScope.$apply()

        it 'should reject the promise', ->
          expect(rejected).toBe true


  describe 'saving the device token', ->

    describe 'when using an iOS device', ->
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
          $rootScope.$apply()

        it 'should resolve the promise', ->
          expect(resolved).toBe true

      describe 'save failed', ->

        beforeEach ->
          deferred.reject()
          $rootScope.$apply()

        it 'should reject the promise', ->
          expect(rejected).toBe true


    describe 'when using an iOS device', ->
      device = null
      deviceToken = null
      deferred = null
      resolved = null
      rejected = null

      beforeEach ->
        deviceToken = '1234'

        device =
          cordova: '5.0'
          model: 'That Shitty Galaxy Phone 3'
          platform: 'Android'
          uuid: '1234'
          version: '1.3'
        $cordovaDevice.getDevice.and.returnValue device

        deferred = $q.defer()
        spyOn(GCMDevice, 'save').and.returnValue {$promise: deferred.promise}

        PushNotifications.saveToken(deviceToken).then ->
          resolved = true
        , ->
          rejected = true

      it 'should create a new APNSDevice and call save', ->
        name = device.model + ', ' + device.version
        gcmDevice =
          userId: Auth.user.id
          registrationId: deviceToken
          deviceId: device.uuid
          name: name
        expect(GCMDevice.save).toHaveBeenCalledWith gcmDevice

      describe 'successfully', ->

        beforeEach ->
          deferred.resolve()
          $rootScope.$apply()

        it 'should resolve the promise', ->
          expect(resolved).toBe true

      describe 'save failed', ->

        beforeEach ->
          deferred.reject()
          $rootScope.$apply()

        it 'should reject the promise', ->
          expect(rejected).toBe true

  describe 'listening for notifications', ->

    describe 'when using an iOS device', ->

      describe 'when we have already request push permissions', ->

        beforeEach ->
          localStorage.set 'hasRequestedPushNotifications', true
          $cordovaDevice.getPlatform.and.returnValue 'iOS'
          spyOn PushNotifications, 'register'

          PushNotifications.listen()

        it 'should call register', ->
          expect(PushNotifications.register).toHaveBeenCalled()


    describe 'when using an Android device', ->

      beforeEach ->        
        $cordovaDevice.getPlatform.and.returnValue 'Android'
        spyOn PushNotifications, 'register'

        PushNotifications.listen()
          
      it 'should call register', ->
        expect(PushNotifications.register).toHaveBeenCalled()


    describe 'when a notification is recieved', ->

      beforeEach ->
        spyOn PushNotifications, 'handleNotification'

        PushNotifications.listen()

        $rootScope.$broadcast '$cordovaPush:notificationReceived'
        $rootScope.$apply()

      it 'should call handle notification', ->
        expect(PushNotifications.handleNotification).toHaveBeenCalled()


  describe 'handling notifications', ->

    describe 'when using an iOS device', ->
      beforeEach ->
        $cordovaDevice.getPlatform.and.returnValue 'iOS'

      describe 'when notification has an alert', ->
        alert = null
      
        beforeEach ->
          alert = 'Chris MacPherson add you back!'
          notification =
            alert: alert

          spyOn ngToast, 'create'

          PushNotifications.handleNotification null, notification

        it 'should show a notification', ->
          expect(ngToast.create).toHaveBeenCalledWith alert


      describe 'when notification is for a new invitation', ->
        alert = null
      
        beforeEach ->
          alert = 'from Chris MacPherson'
          notification =
            alert: alert

          spyOn ngToast, 'create'

          PushNotifications.handleNotification null, notification

        it 'should show add "Down. " to the alert and show a notification', ->
          expect(ngToast.create).toHaveBeenCalledWith "Down. #{alert}"


      xdescribe 'when notification has a sound', ->
        event = null

        beforeEach ->
          event =
            sound: 'some sound'


    describe 'when using an Android device', ->
      beforeEach ->
        $cordovaDevice.getPlatform.and.returnValue 'Android'

      describe 'when notification is a message', ->
        message = null

        beforeEach ->
          message = 'Chris MacPherson add you back!'
          notification =
            message: message
            event: 'message'

          spyOn ngToast, 'create'

          PushNotifications.handleNotification null, notification

        it 'should show a notification', ->
          expect(ngToast.create).toHaveBeenCalledWith message
