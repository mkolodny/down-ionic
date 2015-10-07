require '../common/auth/auth-module'
require '../common/friendship-button/friendship-button-module'
require '../common/resources/resources-module'
AddedMeCtrl = require './added-me-controller'

angular.module 'down.addedMe', [
    'ui.router'
    'down.auth'
    'down.friendshipButton'
    'down.resources'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addedMe',
      url: '/added-me'
      templateUrl: 'app/added-me/added-me.html'
      controller: 'AddedMeCtrl as addedMe'
  .controller 'AddedMeCtrl', AddedMeCtrl
