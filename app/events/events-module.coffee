require 'ng-toast'
require '../common/resources/resources-module'
require '../common/event-item/event-item-module'
require '../common/mixpanel/mixpanel-module'
EventsCtrl = require './events-controller'

angular.module 'rallytap.events', [
    'analytics.mixpanel'
    'angular-meteor'
    'rallytap.resources'
    'rallytap.eventItem'
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
