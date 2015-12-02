require 'ng-toast'
require '../common/resources/resources-module'
require '../common/invite-button/invite-button-module'
EventsCtrl = require './events-controller'

angular.module 'rallytap.events', [
    'angular-meteor'
    'rallytap.resources'
    'rallytap.inviteButton'
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
