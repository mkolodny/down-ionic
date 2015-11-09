require 'angular-chart.js'
require 'angular-elastic'
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/select-friend-button/select-friend-button-module'
require '../common/place-autocomplete/place-autocomplete-module'
require '../common/resources/resources-module'
require '../common/mixpanel/mixpanel-module'
require '../common/view-place/view-place-module'
EventsCtrl = require './events-controller'

angular.module 'rallytap.events', [
    'angular-meteor' # required in app-module for tests
    'analytics.mixpanel'
    'chart.js'
    'rallytap.auth'
    'rallytap.selectFriendButton'
    'rallytap.placeAutocomplete'
    'rallytap.resources'
    'rallytap.viewPlace'
    'ionic'
    'monospaced.elastic'
    'ngToast'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'events',
      url: '/'
      templateUrl: 'app/events/events.html'
      controller: 'EventsCtrl as events'
  .controller 'EventsCtrl', EventsCtrl
