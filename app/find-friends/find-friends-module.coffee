require 'angular'
require 'angular-ui-router'
require 'angular-local-storage'
require '../common/auth/auth-module'
require '../common/contacts/contacts-module'
require '../common/resources/resources-module'
require '../common/friendship-button/friendship-button-module'
FindFriendsCtrl = require './find-friends-controller'

angular.module 'down.findFriends', [
    'ui.router'
    'ionic'
    'down.resources'
    'down.auth'
    'down.contacts'
    'down.friendshipButton'
    'LocalStorageModule'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'findFriends',
      url: '/find-friends'
      templateUrl: 'app/find-friends/find-friends.html'
      controller: 'FindFriendsCtrl as findFriends'
  .controller 'FindFriendsCtrl', FindFriendsCtrl
