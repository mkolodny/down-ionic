require 'angular'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/friendship-button/friendship-button-module'
require '../common/resources/resources-module'
AddByUsernameCtrl = require './add-by-username-controller'

angular.module 'down.addByUsername', [
    'ui.router'
    'down.auth'
    'down.resources'
    'down.friendshipButton'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addByUsername',
      url: '/add-by-username'
      templateUrl: 'app/add-by-username/add-by-username.html'
      controller: 'AddByUsernameCtrl as addByUsername'
  .controller 'AddByUsernameCtrl', AddByUsernameCtrl
