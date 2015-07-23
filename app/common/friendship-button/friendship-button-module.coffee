require 'angular'
friendshipButton = require './friendship-button-directive'

angular.module 'down.friendshipButton', []
  .directive 'friendshipButton', friendshipButton
