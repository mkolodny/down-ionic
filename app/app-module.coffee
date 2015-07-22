require 'angular'
require 'angular-ui-router'
require './login/login-module'
require './verify-phone/verify-phone-module'
require './facebook-sync/facebook-sync-module'
require './set-username/set-username-module'
require './request-push/request-push-module'
require './request-location/request-location-module'

angular.module 'down', [
    'ionic'
    'down.login'
    'down.verifyPhone'
    'down.facebookSync'
    'down.setUsername'
    'down.requestPush'
    'down.requestLocation'
  ]
  .config ($httpProvider, $urlRouterProvider) ->
    $httpProvider.defaults.headers.common['Accept'] = 'application/json; version=1.2'
    $urlRouterProvider.when '', '/login'
  .run ($ionicPlatform, $window) ->
    $ionicPlatform.ready ->
      # Hide the accessory bar by default (remove this to show the accessory bar
      # above the keyboard for form inputs)
      $window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar true
      $window.StatusBar?.styleDefault()
