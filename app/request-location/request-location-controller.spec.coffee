require 'angular'
require 'angular-mocks'
require 'ng-cordova'
RequestLocationCtrl = require './request-location-controller'

describe 'request location controller', ->
  $state = null
  scope = null
  ctrl = null

  beforeEach angular.mock.module('down.requestLocation')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()

    ctrl = $controller RequestLocationCtrl,
      $scope: scope
  )

  describe 'enabling location services', ->
