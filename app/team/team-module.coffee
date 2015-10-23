require 'angular-ui-router'
require '../common/auth/auth-module'
TeamCtrl = require './team-controller'

angular.module 'rallytap.team', [
    'rallytap.auth'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'team',
      url: '/team'
      templateUrl: 'app/team/team.html'
      controller: 'TeamCtrl as team'
  .controller 'TeamCtrl', TeamCtrl
