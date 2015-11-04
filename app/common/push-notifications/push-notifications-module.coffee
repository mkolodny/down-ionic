require 'ng-cordova'
require 'ng-toast'
require '../auth/auth-module'
require '../resources/resources-module'
require '../env/env-module'
require '../local-db/local-db-module'

PushNotifications = require './push-notifications-service'

angular.module 'rallytap.pushNotifications', [
    'rallytap.resources'
    'rallytap.auth'
    'rallytap.env'
    'rallytap.localDB'
    'ngCordova'
    'ngToast'
    'ionic'
  ]
  .service 'PushNotifications', PushNotifications
