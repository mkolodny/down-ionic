require 'angular-elastic'
require '../common/auth/auth-module'
FriendChatCtrl = require './friend-chat-controller'

angular.module 'rallytap.friendChat', [
    'ionic'
    'rallytap.auth'
    'monospaced.elastic'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'tabs.chats.friendChat',
      url: '/friend/:id'
      templateUrl: 'app/friend-chat/friend-chat.html'
      controller: 'FriendChatCtrl as friendChat'
      params:
        ###
        friend =
          id: 1
          email: 'benihana@gmail.com'
          name: 'Benny Hana'
          username: 'benihana'
          imageUrl: 'https://facebook.com/profile-pics/benihana'
          location:
            lat: 40.7265834
            long: -73.9821535
        ###
        friend: null
  .controller 'FriendChatCtrl', FriendChatCtrl
