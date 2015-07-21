require 'angular'
require 'angular-mocks'
require 'ng-cordova'
RequestPushCtrl = require './request-push-controller'

describe 'request push controller', ->
  $state = null
  scope = null
  ctrl = null

  beforeEach angular.mock.module('down.requestPush')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()

    ctrl = $controller RequestPushCtrl,
      $scope: scope
  )

  describe 'enabling push notifications', ->
