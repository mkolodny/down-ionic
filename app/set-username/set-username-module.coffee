require 'angular'
require 'angular-ui-router'
require '../common/resources/resources-module'
SetUsernameCtrl = require './set-username-controller'

angular.module 'down.setUsername', [
    'ui.router'
    'down.resources'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'setUsername',
      url: '/set-username'
      templateUrl: 'app/set-username/set-username.html'
      controller: 'SetUsernameCtrl as setUsername'
  .controller 'SetUsernameCtrl', SetUsernameCtrl
