require 'angular-elastic'
require '../common/auth/auth-module'
require '../common/messages/messages-module'
FriendChatCtrl = require './friend-chat-controller'

angular.module 'rallytap.friendChat', [
    'ionic'
    'rallytap.auth'
    'rallytap.messages'
    'monospaced.elastic'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'friendChat',
      parent: 'chats'
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
