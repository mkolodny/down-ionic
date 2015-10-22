require '../common/auth/auth-module'
VerifyPhoneCtrl = require './verify-phone-controller'

angular.module 'rallytap.verifyPhone', [
    'angular-meteor' # required in app-module for tests
    'ui.router'
    'rallytap.auth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'verifyPhone',
      url: '/verify-phone'
      templateUrl: 'app/verify-phone/verify-phone.html'
      controller: 'VerifyPhoneCtrl as verifyPhone'
  .controller 'VerifyPhoneCtrl', VerifyPhoneCtrl
