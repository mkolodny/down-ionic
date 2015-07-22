require 'angular'
require 'angular-ui-router'
AddFriendsSignupCtrl = require './add-friends-signup-controller'

angular.module 'down.addFriendsSignup', [
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFriendsSignup',
      url: '/new/add-friends'
      templateUrl: 'app/add-friends-signup/add-friends-signup.html'
      controller: 'AddFriendsSignupCtrl as addFriendsSignup'
  .controller 'AddFriendsSignupCtrl', AddFriendsSignupCtrl
