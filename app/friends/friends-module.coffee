require '../common/points/points-module'
require '../common/mixpanel/mixpanel-module'
FriendsCtrl = require './friends-controller'

angular.module 'rallytap.friends', [
    'analytics.mixpanel'
    'rallytap.points'
    'ngCordova'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'manageFriends',
      url: ''
      parent: 'friends'
      templateUrl: 'app/friends/friends.html'
      controller: 'FriendsCtrl as friends'
  .controller 'FriendsCtrl', FriendsCtrl
