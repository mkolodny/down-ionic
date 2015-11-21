require 'angular-chart.js'
require 'angular-elastic'
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/place-autocomplete/place-autocomplete-module'
require '../common/resources/resources-module'
require '../common/mixpanel/mixpanel-module'
require '../common/view-place/view-place-module'
ChatsCtrl = require './chats-controller'

angular.module 'rallytap.chats', [
    'angular-meteor' # required in app-module for tests
    'analytics.mixpanel'
    'chart.js'
    'rallytap.auth'
    'rallytap.placeAutocomplete'
    'rallytap.resources'
    'rallytap.viewPlace'
    'ionic'
    'monospaced.elastic'
    'ngToast'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'chats.list',
      url: ''
      templateUrl: 'app/chats/chats.html'
      controller: 'ChatsCtrl as chats'
  .controller 'ChatsCtrl', ChatsCtrl
