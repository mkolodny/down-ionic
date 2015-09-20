require 'angular'
require 'ng-cordova'
require 'angular-ui-router'
require 'angular-local-storage'
require '../angular-mixpanel/angular-mixpanel-module'
require '../resources/resources-module'
require '../asteroid/asteroid-module'
Auth = require './auth-service'

angular.module 'down.auth', [
    'analytics.mixpanel'
    'down.asteroid'
    'down.resources'
    'ui.router'
    'ngCordova'
    'LocalStorageModule'
  ]
  .service 'Auth', Auth
