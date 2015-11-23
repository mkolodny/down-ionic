require 'angular-local-storage'
require 'angular-resource'
require 'angular-ui-router'
require 'angular-elastic'
require 'ng-toast'
require '../env/env-module'
require '../auth/auth-module'
require '../mixpanel/mixpanel-module'
APNSDevice = require './apnsdevice-service'
Event = require './event-service'
Friendship = require './friendship-service'
GCMDevice = require './gcmdevice-service'
User = require './user-service'
UserPhone = require './userphone-service'
SavedEvent = require './saved-event-service'
RecommendedEvent = require './recommended-event-service'

angular.module 'rallytap.resources', [
    'angular-meteor' # required in app-module for tests
    'analytics.mixpanel'
    'ngResource'
    'rallytap.auth'
    'rallytap.env'
    'LocalStorageModule'
    'ngToast'
  ]
  .factory 'APNSDevice', APNSDevice
  .factory 'Event', Event
  .factory 'Friendship', Friendship
  .factory 'GCMDevice', GCMDevice
  .factory 'User', User
  .factory 'UserPhone', UserPhone
  .factory 'SavedEvent', SavedEvent
  .factory 'RecommendedEvent', RecommendedEvent
