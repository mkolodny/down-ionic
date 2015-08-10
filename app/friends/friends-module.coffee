require 'angular'
require 'angular-ui-router'
require '../common/auth/auth-module'
FriendsCtrl = require './friends-controller'

angular.module 'down.friends', [
    'ui.router'
    'down.auth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'friends',
      url: '/friends'
      templateUrl: 'app/friends/friends.html'
      controller: 'FriendsCtrl as friends'
      cache: false
  .controller 'FriendsCtrl', FriendsCtrl
