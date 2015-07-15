require 'angular'
require 'angular-resource'
APNSDevice = require './apnsdevice-service'

angular.module 'down.resources', ['ngResource']
  .value 'apiRoot', '/api'
  .factory 'APNSDevice', APNSDevice
