require '../common/auth/auth-module'
require '../common/contacts/contacts-module'
require '../common/resources/resources-module'
require '../common/friendship-button/friendship-button-module'
FindFriendsCtrl = require './find-friends-controller'

angular.module 'rallytap.findFriends', [
    'ui.router'
    'ionic'
    'rallytap.resources'
    'rallytap.auth'
    'rallytap.contacts'
    'rallytap.friendshipButton'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'findFriends',
      url: '/find-friends'
      templateUrl: 'app/find-friends/find-friends.html'
      controller: 'FindFriendsCtrl as findFriends'
  .controller 'FindFriendsCtrl', FindFriendsCtrl
