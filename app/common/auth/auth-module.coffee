require 'angular-ui-router'
require 'ng-cordova'
require '../mixpanel/mixpanel-module'
require '../resources/resources-module'
require '../local-db/local-db-module'
Auth = require './auth-service'

angular.module 'rallytap.auth', [
    'angular-meteor' # required in app module for testing
    'analytics.mixpanel'
    'rallytap.resources'
    'rallytap.localDB'
    'ui.router'
    'ngCordova'
  ]
  .service 'Auth', Auth
