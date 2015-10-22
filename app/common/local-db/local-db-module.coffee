require 'angular-local-storage'
require '../ng-cordova/sqlite.js'
LocalDB = require './local-db-service'

angular.module 'rallytap.localDB', [
    'ngCordova.plugins.sqlite'
    'LocalStorageModule'
  ]
  .service 'LocalDB', LocalDB
