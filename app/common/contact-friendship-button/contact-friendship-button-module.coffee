require 'angular'
require '../resources/resources-module'
contactFriendshipButton = require './contact-friendship-button-directive'

angular.module 'down.contactFriendshipButton', [
    'down.resources'
  ]
  .directive 'contactFriendshipButton', contactFriendshipButton
