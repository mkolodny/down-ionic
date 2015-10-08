require 'ng-cordova'
require 'ng-toast'
require 'angular-local-storage'
require '../auth/auth-module'
require '../../ionic/ionic-core.js'
require '../resources/resources-module'
require '../env/env-module'

PushNotifications = require './push-notifications-service'

angular.module 'down.pushNotifications', [
    'down.resources'
    'down.auth'
    'down.env'
    'LocalStorageModule'
    'ngCordova'
    'ngToast'
    'ionic'
  ]
  .service 'PushNotifications', PushNotifications
