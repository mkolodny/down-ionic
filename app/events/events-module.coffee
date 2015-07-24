require 'angular'
require 'angular-ui-router'
require '../common/auth/auth-module'
EventsCtrl = require './events-controller'

angular.module 'down.events', [
    'ui.router'
    'down.resources'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'events',
      url: '/'
      templateUrl: 'app/events/events.html'
      controller: 'EventsCtrl as events'
  .controller 'EventsCtrl', EventsCtrl
