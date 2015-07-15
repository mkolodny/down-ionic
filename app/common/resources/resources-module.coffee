require 'angular'
require 'angular-resource'
APNSDevice = require './apnsdevice-service'
Event = require './event-service'

angular.module 'down.resources', ['ngResource']
  .value 'apiRoot', '/api'
  .factory 'APNSDevice', APNSDevice
  .factory 'Event', Event
