require 'angular-ui-router'
require 'ng-toast'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
MyEventsCtrl = require './my-events-controller'

angular.module 'rallytap.myEvents', [
    'rallytap.auth'
    'rallytap.resources'
    'ui.router'
    'ngToast'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'tabs.saved.myEvents',
      url: ''
      templateUrl: 'app/my-events/my-events.html'
      controller: 'MyEventsCtrl as myEvents'
  .controller 'MyEventsCtrl', MyEventsCtrl
