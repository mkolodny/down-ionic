FriendsCtrl = require './friends-controller'

angular.module 'rallytap.friends', [
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'friends.init',
      url: ''
      templateUrl: 'app/friends/friends.html'
      controller: 'FriendsCtrl as friends'
  .controller 'FriendsCtrl', FriendsCtrl
