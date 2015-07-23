require 'angular'
require 'ng-cordova'
require '../resources/resources-module'
Auth = require './auth-service'

angular.module 'down.auth', [
    'down.resources'
    'ngCordova.plugins.geolocation'
  ]
  .service 'Auth', Auth
