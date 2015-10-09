require './angular-pouchdb'
LocalDB = require './local-db-service'

angular.module 'down.localDB', [
    'pouchdb'
  ]
  .service 'LocalDB', LocalDB
