require 'angular'
require 'angular-mocks'
require 'ng-cordova'
RequestLocationCtrl = require './request-location-controller'

describe 'request location controller', ->
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

    ctrl = $controller RequestLocationCtrl,
      $scope: scope
      Auth: Auth
  )

  describe 'enabling location services', ->

    afterEach ->
      localStorage.clearAll()

    it 'should set the hasAllowedLocationServices to true', ->
      ctrl.enableLocation()
      expect(localStorage.hasAllowedLocationServices).toBe true

    describe 'permission granted', ->

      # it 'should save the users location', ->
      #   describe 'save sucessful', ->
      #     it 'should set Auth.user', ->

      it 'should start saving the users location', ->
        

      describe 'user has completed sign up before', ->

        it 'should send the user to the feed view', ->

      describe 'user has not completed sign up', ->

        it 'should send the user to add friends on sign up view', ->

        # describe 'save failed', ->
        #   it 'should display an error', ->

    describe 'permission denied', ->

      it 'should display an error', ->
