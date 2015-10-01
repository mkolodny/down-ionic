require 'angular'
require 'angular-local-storage'
require 'angular-resource'
require '../auth/auth-module'
require '../env/env-module'
require '../mixpanel/mixpanel-module'
APNSDevice = require './apnsdevice-service'
Event = require './event-service'
Friendship = require './friendship-service'
GCMDevice = require './gcmdevice-service'
Invitation = require './invitation-service'
LinkInvitation = require './linkinvitation-service'
User = require './user-service'
UserPhone = require './userphone-service'

angular.module 'down.resources', [
    'angular-meteor' # required in app-module for tests
    'analytics.mixpanel'
    'ngResource'
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
