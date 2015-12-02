require '../common/auth/auth-module'
require '../common/intl-phone/intl-phone-module'
MyFriendsCtrl = require './my-friends-controller'

angular.module 'rallytap.myFriends', [
    'ui.router'
    'rallytap.auth'
    'rallytap.intlPhone'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'myFriends',
      url: '/my-friends'
      parent: 'friends'
      templateUrl: 'app/my-friends/my-friends.html'
      controller: 'MyFriendsCtrl as myFriends'
  .controller 'MyFriendsCtrl', MyFriendsCtrl
