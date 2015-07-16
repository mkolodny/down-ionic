require 'angular'
require 'angular-resource'
AllFriendsInvitation = require './allfriendsinvitation-service'
APNSDevice = require './apnsdevice-service'
Event = require './event-service'
Friendship = require './friendship-service'
Invitation = require './invitation-service'
LinkInvitation = require './linkinvitation-service'
User = require './user-service'

angular.module 'down.resources', ['ngResource']
  .value 'apiRoot', '/api'
  .factory 'APNSDevice', APNSDevice
  .factory 'Event', Event
  .factory 'Friendship', Friendship
  .factory 'Invitation', Invitation
  .factory 'AllFriendsInvitation', AllFriendsInvitation
  .factory 'LinkInvitation', LinkInvitation
  .factory 'User', User
