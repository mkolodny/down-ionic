require 'angular-local-storage'
require '../common/auth/auth-module'
VerifyPhoneCtrl = require './verify-phone-controller'

angular.module 'down.verifyPhone', [
    'angular-meteor' # required in app-module for tests
    'ui.router'
    'down.auth'
    'LocalStorageModule'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'verifyPhone',
      url: '/verify-phone'
      templateUrl: 'app/verify-phone/verify-phone.html'
      controller: 'VerifyPhoneCtrl as verifyPhone'
  .controller 'VerifyPhoneCtrl', VerifyPhoneCtrl
