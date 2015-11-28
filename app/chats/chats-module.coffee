require 'angular-chart.js'
require 'angular-elastic'
require '../common/auth/auth-module'
require '../common/resources/resources-module'
ChatsCtrl = require './chats-controller'

angular.module 'rallytap.chats', [
    'angular-meteor' # required in app-module for tests
    'chart.js'
    'rallytap.auth'
    'rallytap.resources'
    'monospaced.elastic'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'tabs.chats.list',
      url: ''
      templateUrl: 'app/chats/chats.html'
      controller: 'ChatsCtrl as chats'
  .controller 'ChatsCtrl', ChatsCtrl
