require 'angular-elastic'
require 'ng-toast'
require '../mixpanel/mixpanel-module'
require '../invite-button/invite-button-module'
require '../auth/auth-module'
EventItemCtrl = require './event-item-controller'
EventItemDirective = require './event-item-directive'

angular.module 'rallytap.eventItem', [
    'angular-meteor'
    'analytics.mixpanel'
    'rallytap.auth'
    'rallytap.resources'
    'rallytap.inviteButton'
    'ngToast'
    'ui.router'
  ]
  .controller 'eventItemCtrl', EventItemCtrl
  .directive 'eventItem', EventItemDirective
