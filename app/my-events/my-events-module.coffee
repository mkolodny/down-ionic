require 'angular-ui-router'
require 'ng-toast'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
require '../common/event-item/event-item-module'
require '../common/points/points-module'
MyEventsCtrl = require './my-events-controller'

angular.module 'rallytap.myEvents', [
    'angular-meteor'
    'rallytap.auth'
    'rallytap.eventItem'
    'rallytap.points'
    'rallytap.resources'
    'ui.router'
    'ngToast'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'myEvents',
      url: ''
      parent: 'saved'
      templateUrl: 'app/my-events/my-events.html'
      controller: 'MyEventsCtrl as myEvents'
  .controller 'MyEventsCtrl', MyEventsCtrl
