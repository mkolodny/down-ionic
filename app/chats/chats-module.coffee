require 'angular-chart.js'
require 'angular-elastic'
require 'angular-timeago'
require '../common/auth/auth-module'
require '../common/points/points-module'
require '../common/resources/resources-module'
ChatsCtrl = require './chats-controller'

angular.module 'rallytap.chats', [
    'angular-meteor' # required in app-module for tests
    'chart.js'
    'rallytap.auth'
    'rallytap.points'
    'rallytap.resources'
    'monospaced.elastic'
    'ui.router'
    'yaru22.angular-timeago'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'list',
      url: ''
      parent: 'chats'
      templateUrl: 'app/chats/chats.html'
      controller: 'ChatsCtrl as chats'
  .controller 'ChatsCtrl', ChatsCtrl
