require 'angular-elastic'
require 'ng-toast'
require '../mixpanel/mixpanel-module'
inviteButton = require './invite-button-directive'

angular.module 'rallytap.inviteButton', [
    'angular-meteor'
    'analytics.mixpanel'
    'ngToast'
    'ui.router'
  ]
  .directive 'inviteButton', inviteButton
