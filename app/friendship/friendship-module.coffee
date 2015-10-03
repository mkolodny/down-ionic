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
      url: '/friendship'
      templateUrl: 'app/friendship/friendship.html'
      controller: 'FriendshipCtrl as friendship'
  .controller 'FriendshipCtrl', FriendshipCtrl
