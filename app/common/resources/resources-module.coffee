require 'angular'
require 'angular-local-storage'
require 'angular-resource'
require '../asteroid/asteroid-module'
require '../auth/auth-module'
require '../env/env-module'
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
    'down.env'
    'LocalStorageModule'
  ]
  .factory 'APNSDevice', APNSDevice
  .factory 'Event', Event
  .factory 'Friendship', Friendship
  .factory 'GCMDevice', GCMDevice
  .factory 'Invitation', Invitation
  .factory 'LinkInvitation', LinkInvitation
  .factory 'User', User
  .factory 'UserPhone', UserPhone
