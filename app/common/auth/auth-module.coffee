require 'angular'
require 'ng-cordova'
require 'angular-ui-router'
require '../resources/resources-module'
Auth = require './auth-service'

angular.module 'down.auth', [
    'down.resources'
    'ui.router'
    'ngCordova.plugins.geolocation'
  ]
  .service 'Auth', Auth
