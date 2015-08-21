require 'angular'
require 'angular-ui-router'
FriendsCtrl = require './friends-controller'

angular.module 'down.friends', [
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'friends',
      url: '/friends'
      templateUrl: 'app/friends/friends.html'
      controller: 'FriendsCtrl as friends'
  .controller 'FriendsCtrl', FriendsCtrl
