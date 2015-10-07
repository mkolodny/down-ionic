viewPlace = require './view-place-directive'

angular.module 'down.viewPlace', [
    'ionic'
    'down.resources'
  ]
  .directive 'viewPlace', viewPlace
