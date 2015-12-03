require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require '../common/auth/auth-module'
TabsCtrl = require './tabs-controller'

describe 'tabs controller', ->
  ctrl = null
  scope = null
  Messages = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('rallytap.messages')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    scope = $injector.get '$rootScope'
    Messages = $injector.get 'Messages'

    ctrl = $controller TabsCtrl,
      $scope: scope
  )


 