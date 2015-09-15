require 'angular'
require 'angular-local-storage'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/resources/resources-module'
InviteFriendsCtrl = require './invite-friends-controller'

angular.module 'down.inviteFriends', [
    'ionic'
    'ui.router'
    'down.auth'
    'down.resources'
    'LocalStorageModule'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'inviteFriends',
      url: '/send-suggestion'
      templateUrl: 'app/invite-friends/invite-friends.html'
      controller: 'InviteFriendsCtrl as inviteFriends'
      params:
        ###
        event:
          title: 'bars?!?!!?'
          creator: 2
          canceled: false
          datetime: new Date()
          place:
            name: 'B Bar & Grill'
            lat: 40.7270718
            long: -73.9919324
        ###
        event: null
        ###
        respondedUserIds: [1, 2, 3] Array of user ids
        ###
        respondedUserIds: null
  .controller 'InviteFriendsCtrl', InviteFriendsCtrl
