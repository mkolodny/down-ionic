require 'angular'
require 'ng-cordova'
require 'angular-local-storage'
require '../auth/auth-module'
require '../resources/resources-module'
require '../../vendor/intl-phone/libphonenumber-utils.js'

Contacts = require './contacts-service'

angular.module 'down.contacts', [
    'down.resources'
    'down.auth'
    'LocalStorageModule'
    'ngCordova'
  ]
  .service 'Contacts', Contacts
