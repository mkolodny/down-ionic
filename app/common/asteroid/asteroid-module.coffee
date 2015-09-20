require 'angular'
require '../env/env-module'
require '../resources/resources-module'
Asteroid = require './asteroid-service'

angular.module 'down.asteroid', [
    'down.env'
    'down.resources'
  ]
  .service 'Asteroid', Asteroid
