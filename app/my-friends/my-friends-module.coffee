require '../common/auth/auth-module'
MyFriendsCtrl = require './my-friends-controller'

angular.module 'rallytap.myFriends', [
    'ui.router'
    'rallytap.auth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'myFriends',
      url: '/my-friends'
      templateUrl: 'app/my-friends/my-friends.html'
      controller: 'MyFriendsCtrl as myFriends'
  .controller 'MyFriendsCtrl', MyFriendsCtrl
