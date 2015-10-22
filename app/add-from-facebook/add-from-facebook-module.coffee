require 'angular-local-storage'
require '../common/auth/auth-module'
require '../common/friendship-button/friendship-button-module'
AddFromFacebookCtrl = require './add-from-facebook-controller'

angular.module 'rallytap.addFromFacebook', [
    'ui.router'
    'ionic'
    'rallytap.auth'
    'rallytap.friendshipButton'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFromFacebook',
      url: '/add-from-facebook'
      templateUrl: 'app/add-from-facebook/add-from-facebook.html'
      controller: 'AddFromFacebookCtrl as addFromFacebook'
  .controller 'AddFromFacebookCtrl', AddFromFacebookCtrl
