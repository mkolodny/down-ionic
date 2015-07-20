require 'angular'
require 'angular-ui-router'
require '../common/auth/auth-module'
VerifyPhoneCtrl = require './verify-phone-controller'

angular.module 'down.verifyPhone', ['ui.router', 'down.auth']
  .config ($stateProvider) ->
    $stateProvider.state 'verifyPhone',
      url: '/verify-phone'
      templateUrl: '/app/verify-phone/verify-phone.html'
      controller: 'VerifyPhoneCtrl as verifyPhone'
  .controller 'VerifyPhoneCtrl', VerifyPhoneCtrl