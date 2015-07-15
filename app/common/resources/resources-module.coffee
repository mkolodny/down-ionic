require 'angular'
require 'angular-resource'
APNSDevice = require './apnsdevice-service'
Event = require './event-service'
Friendship = require './friendship-service'

angular.module 'down.resources', ['ngResource']
  .value 'apiRoot', '/api'
  .factory 'APNSDevice', APNSDevice
  .factory 'Event', Event
  .factory 'Friendship', Friendship
