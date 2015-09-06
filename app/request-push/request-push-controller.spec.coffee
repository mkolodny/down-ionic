require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-local-storage'
require '../ionic/ionic-angular.js'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
require '../common/push-notifications/push-notifications-module'
RequestPushCtrl = require './request-push-controller'

describe 'request push controller', ->
  $ionicLoading = null
  $state = null
  $q = null
  scope = null
  ctrl = null
  localStorage = null
  Auth = null
  PushNotifications = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.pushNotifications')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicLoading = $injector.get '$ionicLoading'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $q = $injector.get '$q'
    scope = $rootScope.$new()
    localStorage = $injector.get 'localStorageService'
    PushNotifications = $injector.get 'PushNotifications'
    Auth = $injector.get 'Auth'

    ctrl = $controller RequestPushCtrl,
      $scope: scope
      Auth: Auth
  )

  afterEach ->
    localStorage.clearAll()

  describe 'requesting push notifications permission', ->
    deferred = null
    
    beforeEach ->
      deferred = $q.defer()
      spyOn(PushNotifications, 'register').and.returnValue deferred.promise

      spyOn Auth, 'redirectForAuthState'
      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'

      ctrl.enablePush()

    it 'should show a loading indicator', ->
      expect($ionicLoading.show).toHaveBeenCalled()


    describe 'registered successfully', ->

      beforeEach ->
        deferred.resolve()
        scope.$apply()

      it 'should set hasRequestedPushNotifications to true', ->
        expect(localStorage.get('hasRequestedPushNotifications')).toBe true

      it 'should redirect for auth state', ->
        expect(Auth.redirectForAuthState).toHaveBeenCalled()

      it 'should hide the loading indicator', ->
        expect($ionicLoading.hide).toHaveBeenCalled()




