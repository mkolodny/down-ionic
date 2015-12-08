require '../auth/auth-module'
Points = require './points-service'

angular.module 'rallytap.points', [
    'ionic'
    'rallytap.auth'
  ]
  .service 'Points', Points
