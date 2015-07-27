require 'angular'
require 'angular-ui-router'
require 'ng-cordova'
require '../common/auth/auth-module'
RequestLocationCtrl = require './request-location-controller'

angular.module 'down.requestLocation', [
    'ui.router'
    'ngCordova.plugins.geolocation',
    'down.auth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestLocation',
      url: '/location-services'
      templateUrl: 'app/request-location/request-location.html'
      controller: 'RequestLocationCtrl as requestLocation'
  .controller 'RequestLocationCtrl', RequestLocationCtrl
