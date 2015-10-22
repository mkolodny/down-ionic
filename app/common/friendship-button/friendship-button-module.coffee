require '../mixpanel/mixpanel-module'
friendshipButton = require './friendship-button-directive'

angular.module 'rallytap.friendshipButton', [
    'analytics.mixpanel'
    'ui.router'
  ]
  .directive 'friendshipButton', friendshipButton
