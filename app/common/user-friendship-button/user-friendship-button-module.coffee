require 'angular'
userFriendshipButton = require './user-friendship-button-directive'

angular.module 'down.userFriendshipButton', []
  .directive 'userFriendshipButton', userFriendshipButton
