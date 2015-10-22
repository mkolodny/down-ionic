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

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $q = $injector.get '$q'
    scope = $rootScope.$new()
    Auth = $injector.get 'Auth'

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

    it 'should start watching the users location', ->
      expect(Auth.watchLocation).toHaveBeenCalled()

    # Note: Permission denied case handled by Auth.watchLocation
    describe 'permission granted', ->

      beforeEach ->
        spyOn Auth, 'redirectForAuthState'
        spyOn Auth, 'setFlag'

        deferred.resolve()
        scope.$apply()

      it 'should redirect for auth state', ->
        expect(Auth.redirectForAuthState).toHaveBeenCalled()

      it 'should set the hasRequestLocationServices flag to true', ->
        expect(Auth.setFlag).toHaveBeenCalledWith 'hasRequestedLocationServices', true


    describe 'permission denied', ->

      beforeEach ->
        spyOn Auth, 'redirectForAuthState'

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.locationDenied).toBe true
