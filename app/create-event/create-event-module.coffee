require 'ng-cordova'
CreateEventCtrl = require './create-event-controller'

angular.module 'rallytap.createEvent', [
    'ngCordova'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'createEvent',
      url: '/create-event'
      templateUrl: 'app/create-event/create-event.html'
      controller: 'CreateEventCtrl as createEvent'
  .controller 'CreateEventCtrl', CreateEventCtrl
