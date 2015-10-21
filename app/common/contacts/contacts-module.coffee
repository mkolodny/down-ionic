require 'ng-cordova'
require '../auth/auth-module'
require '../resources/resources-module'
require '../local-db/local-db-module'
require '../../vendor/intl-phone/libphonenumber-utils.js'

Contacts = require './contacts-service'

angular.module 'down.contacts', [
    'down.resources'
    'down.auth'
    'down.localDB'
    'ngCordova'
  ]
  .service 'Contacts', Contacts
