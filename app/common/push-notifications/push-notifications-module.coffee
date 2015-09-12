require 'angular'
require 'ng-cordova'
require 'angular-animate' # for ngToast
require 'angular-sanitize' # for ngToast
require 'ng-toast'
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
    'ngToast'
    'ionic'
  ]
  .service 'PushNotifications', PushNotifications
  .value 'androidSenderID', '189543748377'
