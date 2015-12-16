require '../auth/auth-module'
require '../resources/resources-module'
require '../local-db/local-db-module'
require '../../vendor/intl-phone/libphonenumber-utils.js'

Contacts = require './contacts-service'

angular.module 'rallytap.contacts', [
    'rallytap.resources'
    'rallytap.auth'
    'rallytap.localDB'
    'ngCordova'
  ]
  .service 'Contacts', Contacts
