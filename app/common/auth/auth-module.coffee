require 'angular'
require '../resources/resources-module'
Auth = require './auth-service'

angular.module 'down.auth', ['down.resources']
  .service 'Auth', Auth
