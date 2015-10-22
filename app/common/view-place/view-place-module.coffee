viewPlace = require './view-place-directive'

angular.module 'rallytap.viewPlace', [
    'ionic'
    'rallytap.resources'
  ]
  .directive 'viewPlace', viewPlace
