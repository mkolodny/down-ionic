AddFriendsCtrl = require './add-friends-controller'

angular.module 'rallytap.addFriends', [
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFriends',
      url: '/add-friends'
      templateUrl: 'app/add-friends/add-friends.html'
      controller: 'AddFriendsCtrl as addFriends'
  .controller 'AddFriendsCtrl', AddFriendsCtrl
