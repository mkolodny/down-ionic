require 'angular'
require 'angular-ui-router'
require '../mixpanel/mixpanel-module'
friendshipButton = require './friendship-button-directive'

angular.module 'down.friendshipButton', [
    'analytics.mixpanel'
    'ui.router'
  ]
  .directive 'friendshipButton', friendshipButton
