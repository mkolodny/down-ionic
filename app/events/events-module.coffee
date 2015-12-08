require 'ng-toast'
require '../common/resources/resources-module'
require '../common/event-item/event-item-module'
require '../common/mixpanel/mixpanel-module'
require '../common/points/points-module'
EventsCtrl = require './events-controller'

angular.module 'rallytap.events', [
    'analytics.mixpanel'
    'angular-meteor'
    'rallytap.eventItem'
    'rallytap.points'
    'rallytap.resources'
    'ui.router'
    'ngToast'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'events',
      url: ''
      parent: 'home'
      templateUrl: 'app/events/events.html'
      controller: 'EventsCtrl as events'
  .controller 'EventsCtrl', EventsCtrl
