require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $q = null
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'

    # Mock the current user.
    Auth.currentUser = {id: 1}

    ctrl = $controller EventsCtrl,
      $scope: scope
  )

  