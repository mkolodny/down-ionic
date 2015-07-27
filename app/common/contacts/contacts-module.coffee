require 'angular'
require 'ng-cordova'
require 'angular-local-storage'
require '../resources/resources-module'
Contacts = require './contacts-service'

angular.module 'down.contacts', [
    'down.resources'
    'LocalStorageModule'
  ]
  .service 'Contacts', Contacts