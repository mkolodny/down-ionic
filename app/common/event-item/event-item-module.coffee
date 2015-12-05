require 'angular-elastic'
require 'angular-timeago'
require 'ng-toast'
require '../mixpanel/mixpanel-module'
require '../invite-button/invite-button-module'
require '../auth/auth-module'
require '../mixpanel/mixpanel-module'
require '../view-place/view-place-module'
EventItemCtrl = require './event-item-controller'
EventItemDirective = require './event-item-directive'

angular.module 'rallytap.eventItem', [
    'analytics.mixpanel'
    'yaru22.angular-timeago'
    'angular-meteor'
    'analytics.mixpanel'
    'rallytap.auth'
    'rallytap.resources'
    'rallytap.inviteButton'
    'rallytap.viewPlace'
    'ngToast'
    'ui.router'
  ]
  .controller 'eventItemCtrl', EventItemCtrl
  .directive 'eventItem', EventItemDirective
