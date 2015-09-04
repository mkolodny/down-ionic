require 'angular'
require 'ng-cordova'
require 'angular-local-storage'
require '../auth/auth-module'
require '../../ionic/ionic-core.js'
require '../resources/resources-module'

PushNotifications = require './push-notifications-service'

angular.module 'down.pushNotifications', [
    'down.resources'
    'down.auth'
    'LocalStorageModule'
    'ngCordova'
    'ionic'
  ]
  .service 'PushNotifications', PushNotifications
  .value 'androidSenderId', '189543748377'
