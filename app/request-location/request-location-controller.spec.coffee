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

    it 'should set the hasRequestLocationServices to true', ->
      expect(localStorage.get 'hasRequestedLocationServices').toBe true

    it 'should start watching the users location', ->
      expect(Auth.watchLocation).toHaveBeenCalled()

    describe 'permission granted', ->

      beforeEach ->
        deferred.resolve()
        scope.$apply()     

      describe 'user has completed sign up before', ->

        it 'should send the user to the feed view', ->

      describe 'user has not completed sign up', ->

        it 'should send the user to add friends on sign up view', ->
