require 'ng-toast'
require '../common/resources/resources-module'
require '../common/mixpanel/mixpanel-module'
CreateEventCtrl = require './create-event-controller'

angular.module 'rallytap.createEvent', [
    'analytics.mixpanel'
    'rallytap.resources'
    'ngCordova'
    'ui.router'
    'ngToast'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'createEvent',
      url: '/create-event'
      templateUrl: 'app/create-event/create-event.html'
      controller: 'CreateEventCtrl as createEvent'
  .controller 'CreateEventCtrl', CreateEventCtrl
