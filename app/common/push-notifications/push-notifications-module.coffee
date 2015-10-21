require 'ng-cordova'
require 'ng-toast'
require '../auth/auth-module'
require '../../ionic/ionic-core.js'
require '../resources/resources-module'
require '../env/env-module'
require '../local-db/local-db-module'

PushNotifications = require './push-notifications-service'

angular.module 'down.pushNotifications', [
    'down.resources'
    'down.auth'
    'down.env'
    'down.localDB'
    'ngCordova'
    'ngToast'
    'ionic'
  ]
  .service 'PushNotifications', PushNotifications
