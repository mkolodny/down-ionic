require 'angular'
require 'angular-local-storage'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/asteroid/asteroid-module'
VerifyPhoneCtrl = require './verify-phone-controller'

angular.module 'down.verifyPhone', [
    'ui.router'
    'down.auth'
    'LocalStorageModule'
    'down.asteroid'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'verifyPhone',
      url: '/verify-phone'
      templateUrl: 'app/verify-phone/verify-phone.html'
      controller: 'VerifyPhoneCtrl as verifyPhone'
  .controller 'VerifyPhoneCtrl', VerifyPhoneCtrl
