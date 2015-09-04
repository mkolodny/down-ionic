require 'angular'
require '../auth/auth-module'
Asteroid = require './asteroid-service'

angular.module 'down.asteroid', [
    'down.auth'
  ]
  .service 'Asteroid', Asteroid
  .value 'host', 'down-meteor.herokuapp.com'
