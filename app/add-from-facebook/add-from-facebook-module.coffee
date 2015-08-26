require 'angular'
require 'angular-local-storage'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/user-friendship-button/user-friendship-button-module'
require '../common/resources/resources-module'
AddFromFacebookCtrl = require './add-from-facebook-controller'

angular.module 'down.addFromFacebook', [
    'ui.router'
    'ionic'
    'down.auth'
    'down.resources'
    'down.userFriendshipButton'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFromFacebook',
      url: '/add-from-facebook'
      templateUrl: 'app/add-from-facebook/add-from-facebook.html'
      controller: 'AddFromFacebookCtrl as addFromFacebook'
  .controller 'AddFromFacebookCtrl', AddFromFacebookCtrl
