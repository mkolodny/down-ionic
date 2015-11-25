require 'ng-cordova'
CreateEventCtrl = require './create-event-controller'

angular.module 'rallytap.createEvent', [
    'ngCordova'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'tabs.post.createEvent',
      url: ''
      templateUrl: 'app/create-event/create-event.html'
      controller: 'CreateEventCtrl as createEvent'
  .controller 'CreateEventCtrl', CreateEventCtrl
