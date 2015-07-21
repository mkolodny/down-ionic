require 'angular'
require 'angular-ui-router'
require 'ng-cordova'
RequestLocationCtrl = require './request-location-controller'

angular.module 'down.requestLocation', [
    'ui.router'
    'ngCordova.plugins.geolocation'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestLocation',
      url: '/location-services'
      templateUrl: '/app/request-location/request-location.html'
      controller: 'RequestLocationCtrl as requestLocation'
  .controller 'RequestLocationCtrl', RequestLocationCtrl
