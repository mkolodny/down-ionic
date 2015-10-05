require 'angular'
require 'angular-elastic'
require 'angular-ui-router'
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/view-place/view-place-module'
FriendshipCtrl = require './friendship-controller'

angular.module 'down.friendship', [
    'ionic'
    'down.auth'
    'down.viewPlace'
    'monospaced.elastic'
    'ngToast'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'friendship',
      url: '/friendship/:id'
      templateUrl: 'app/friendship/friendship.html'
      controller: 'FriendshipCtrl as friendship'
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
  .controller 'FriendshipCtrl', FriendshipCtrl
