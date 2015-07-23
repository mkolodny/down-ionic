require 'angular'
require 'angular-ui-router'
EventsCtrl = require './events-controller'

angular.module 'down.events', ['ui.router']
  .config ($stateProvider) ->
    $stateProvider.state 'events',
      url: '/'
      templateUrl: 'app/events/events.html'
      controller: 'EventsCtrl as events'
  .controller 'EventsCtrl', EventsCtrl
