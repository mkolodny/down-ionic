require 'angular'
require 'angular-elastic'
require 'angular-ui-router'
require 'angularjs-scroll-glue'
require '../common/auth/auth-module'
FriendshipCtrl = require './friendship-controller'

angular.module 'down.friendship', [
    'down.auth'
    'luegg.directives'
    'monospaced.elastic'
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
