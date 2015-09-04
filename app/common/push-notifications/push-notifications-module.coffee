require 'angular'
require 'ng-cordova'
require 'angular-local-storage'
require '../auth/auth-module'
require '../resources/resources-module'

PushNotifications = require './push-notifications-service'

angular.module 'down.pushNotifications', [
    'down.resources'
    'down.auth'
    'LocalStorageModule'
    'ngCordova'
  ]
  .service 'PushNotifications', PushNotifications
