require '../common/auth/auth-module'
require '../common/resources/resources-module'
require '../common/mixpanel/mixpanel-module'
require '../common/local-db/local-db-module'
InviteFriendsCtrl = require './invite-friends-controller'

angular.module 'rallytap.inviteFriends', [
    'analytics.mixpanel'
    'ionic'
    'ui.router'
    'rallytap.auth'
    'rallytap.resources'
    'rallytap.localDB'
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
