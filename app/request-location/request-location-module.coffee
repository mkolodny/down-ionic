require '../common/auth/auth-module'
RequestLocationCtrl = require './request-location-controller'

angular.module 'rallytap.requestLocation', [
    'ui.router'
    'ngCordova'
    'rallytap.auth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestLocation',
      url: '/location-services'
      templateUrl: 'app/request-location/request-location.html'
      controller: 'RequestLocationCtrl as requestLocation'
  .controller 'RequestLocationCtrl', RequestLocationCtrl
