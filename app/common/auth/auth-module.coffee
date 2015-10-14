require 'ng-cordova'
require '../mixpanel/mixpanel-module'
require '../resources/resources-module'
require '../local-db/local-db-module'
Auth = require './auth-service'

angular.module 'down.auth', [
    'angular-meteor' # required in app module for testing
    'analytics.mixpanel'
    'down.resources'
    'down.localDB'
    'ui.router'
    'ngCordova'
  ]
  .service 'Auth', Auth
