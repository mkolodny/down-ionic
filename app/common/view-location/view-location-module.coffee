require 'angular'
viewLocation = require './view-location-directive'

angular.module 'down.viewLocation', [
    'ionic'
    'down.resources'
  ]
  .directive 'viewLocation', viewLocation
