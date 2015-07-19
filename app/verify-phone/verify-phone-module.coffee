require 'angular'
require 'angular-ui-router'
#require '../common/intl-phone/intl-phone-module'
VerifyPhoneCtrl = require './verify-phone-controller'

angular.module 'down.verifyPhone', ['ui.router']
  .config ($stateProvider) ->
    $stateProvider.state 'verifyPhone',
      url: '/verify-phone'
      templateUrl: '/app/verify-phone/verify-phone.html'
      controller: 'VerifyPhoneCtrl as verifyPhone'
  .controller 'VerifyPhoneCtrl', VerifyPhoneCtrl
