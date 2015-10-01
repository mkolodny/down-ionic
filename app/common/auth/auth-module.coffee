require 'angular'
require 'ng-cordova'
require 'angular-ui-router'
require 'angular-local-storage'
require '../mixpanel/mixpanel-module'
require '../resources/resources-module'
Auth = require './auth-service'

angular.module 'down.auth', [
    'angular-meteor' # required in app module for testing
    'analytics.mixpanel'
    'down.resources'
    'ui.router'
    'ngCordova'
    'LocalStorageModule'
  ]
  .service 'Auth', Auth
