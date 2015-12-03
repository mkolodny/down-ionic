require 'angular-elastic'
require 'ng-toast'
require '../mixpanel/mixpanel-module'
require '../invite-button/invite-button-module'
require '../auth/auth-module'
EventItemCtrl = require './event-item-controller'

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
  .directive 'eventItem', ->
    restrict: 'E'
    scope:
      savedEvent: '='
      commentsCount: '='
    bindToController: true
    templateUrl: 'app/common/event-item/event-item.html'
    controller: 'eventItemCtrl as eventItem'
