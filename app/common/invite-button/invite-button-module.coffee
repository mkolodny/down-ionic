require 'angular-elastic'
require 'ng-toast'
require '../mixpanel/mixpanel-module'
InviteButtonCtrl = require './invite-button-controller'
InviteButtonDirective = require './invite-button-directive'

angular.module 'rallytap.inviteButton', [
    'angular-meteor'
    'analytics.mixpanel'
    'ngToast'
    'ui.router'
  ]
  .controller 'inviteButtonCtrl', InviteButtonCtrl
  .directive 'inviteButton', InviteButtonDirective
