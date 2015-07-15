require 'angular'
Auth = require './auth-service'

angular.module 'down.auth', []
  .service 'Auth', Auth
