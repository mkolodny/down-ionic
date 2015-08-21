require 'angular'
require 'angular-ui-router'
require '../common/auth/auth-module'
MyFriendsCtrl = require './my-friends-controller'

angular.module 'down.myFriends', [
    'ui.router'
    'down.auth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'myFriends',
      url: '/my-friends'
      templateUrl: 'app/my-friends/my-friends.html'
      controller: 'MyFriendsCtrl as myFriends'
  .controller 'MyFriendsCtrl', MyFriendsCtrl
