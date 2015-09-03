require 'angular'
require 'angular-mocks'
require 'ng-cordova'
RequestLocationCtrl = require './request-location-controller'

describe 'request location controller', ->
  $state = null
  $q = null
  scope = null
  Auth = null
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
    $q = $injector.get '$q'
    scope = $rootScope.$new()
    Auth = angular.copy $injector.get('Auth')

    ctrl = $controller RequestLocationCtrl,
      $scope: scope
      Auth: Auth
  )

  describe 'enabling location services', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Auth, 'watchLocation').and.returnValue deferred.promise

      ctrl.enableLocation()

    afterEach ->
      localStorage.clearAll()

    it 'should start watching the users location', ->
      expect(Auth.watchLocation).toHaveBeenCalled()

    # Note: Permission denied case handled by Auth.watchLocation
    describe 'permission granted', ->

      beforeEach ->
        spyOn Auth, 'redirectForAuthState'

        deferred.resolve()
        scope.$apply()

      it 'should redirect for auth state', ->
        expect(Auth.redirectForAuthState).toHaveBeenCalled()

      it 'should set the hasRequestLocationServices to true', ->
        expect(localStorage.get 'hasRequestedLocationServices').toBe true


    describe 'permission denied', ->

      beforeEach ->
        spyOn Auth, 'redirectForAuthState'

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.locationDenied).toBe true
