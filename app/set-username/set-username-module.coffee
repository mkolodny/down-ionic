require '../common/resources/resources-module'
SetUsernameCtrl = require './set-username-controller'

angular.module 'rallytap.setUsername', [
    'ui.router'
    'rallytap.resources'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'setUsername',
      url: '/set-username'
      templateUrl: 'app/set-username/set-username.html'
      controller: 'SetUsernameCtrl as setUsername'
  .controller 'SetUsernameCtrl', SetUsernameCtrl
