require 'angular'
require '../auth/auth-module'
require '../env/env-module'
require '../resources/resources-module'
Asteroid = require './asteroid-service'

angular.module 'down.asteroid', [
    'down.auth'
    'down.env'
    'down.resources'
  ]
  .service 'Asteroid', Asteroid
