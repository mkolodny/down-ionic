require 'angular-local-storage'
require 'angular-meteor'
require 'angular-resource'
require 'angular-ui-router'
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

angular.module 'rallytap.resources', [
    'angular-meteor' # required in app-module for tests
    'analytics.mixpanel'
    'ngResource'
    'rallytap.auth'
    'rallytap.env'
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
