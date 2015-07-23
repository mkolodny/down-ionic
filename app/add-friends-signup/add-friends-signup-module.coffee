require 'angular'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/friendship-button/friendship-button-module'
require '../common/resources/resources-module'
AddFriendsSignupCtrl = require './add-friends-signup-controller'

angular.module 'down.addFriendsSignup', [
    'ui.router'
    'ionic'
    'down.resources'
    'down.auth'
    'down.friendshipButton'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFriendsSignup',
      url: '/new/add-friends'
      templateUrl: 'app/add-friends-signup/add-friends-signup.html'
      controller: 'AddFriendsSignupCtrl as addFriendsSignup'
  .controller 'AddFriendsSignupCtrl', AddFriendsSignupCtrl
