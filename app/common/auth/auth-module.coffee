require 'angular'
require 'ng-cordova'
require 'angular-ui-router'
require 'angular-local-storage'
require '../resources/resources-module'
Auth = require './auth-service'

angular.module 'down.auth', [
    'down.resources'
    'ui.router'
    'ngCordova'
    'LocalStorageModule'
  ]
  .service 'Auth', Auth
