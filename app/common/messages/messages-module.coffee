require '../auth/auth-module'
Messages = require './messages-service'

angular.module 'rallytap.messages', [
    'angular-meteor' # required in app module for testing
    'rallytap.auth'
  ]
  .service 'Messages', Messages
