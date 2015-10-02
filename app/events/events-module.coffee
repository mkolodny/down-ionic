require 'angular'
require 'angular-chart.js'
require 'angular-elastic'
require 'angular-ui-router'
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/place-autocomplete/place-autocomplete-module'
require '../common/resources/resources-module'
require '../common/view-place/view-place-module'
EventsCtrl = require './events-controller'

angular.module 'down.events', [
    'angular-meteor' # required in app-module for tests
    'chart.js'
    'down.auth'
    'down.placeAutocomplete'
    'down.resources'
    'down.viewPlace'
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
