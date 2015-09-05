require 'angular'
require 'angular-local-storage'
require 'angular-resource'
require '../asteroid/asteroid-module'
require '../auth/auth-module'
APNSDevice = require './apnsdevice-service'
Event = require './event-service'
Friendship = require './friendship-service'
GCMDevice = require './gcmdevice-service'
Invitation = require './invitation-service'
LinkInvitation = require './linkinvitation-service'
User = require './user-service'
UserPhone = require './userphone-service'

angular.module 'down.resources', [
    'ngResource'
    'down.asteroid'
    'down.auth'
    'LocalStorageModule'
  ]
  .value 'apiRoot', 'http://down-staging.herokuapp.com/api'
  #.value 'apiRoot', 'http://localhost:8000/api'
  .factory 'APNSDevice', APNSDevice
  .factory 'Event', Event
  .factory 'Friendship', Friendship
  .factory 'GCMDevice', GCMDevice
  .factory 'Invitation', Invitation
  .factory 'LinkInvitation', LinkInvitation
  .factory 'User', User
  .factory 'UserPhone', UserPhone
