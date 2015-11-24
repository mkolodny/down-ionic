require '../common/resources/resources-module'
EventsCtrl = require './events-controller'

angular.module 'rallytap.events', [
    'angular-meteor'
    'rallytap.resources'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'home.events',
      url: ''
      templateUrl: 'app/events/events.html'
      controller: 'EventsCtrl as events'
  .controller 'EventsCtrl', EventsCtrl
