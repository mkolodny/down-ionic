require 'angular'
require 'angular-ui-router'
#require '../common/intl-phone/intl-phone-module'
LoginCtrl = require './login-controller'

angular.module 'down.login', ['ui.router']
  .config ($stateProvider) ->
    $stateProvider.state 'login',
      url: '/login'
      templateUrl: '/app/login/login.html'
      controller: 'LoginCtrl as login'
  .controller 'LoginCtrl', LoginCtrl
