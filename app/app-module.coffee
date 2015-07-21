require 'angular'
require './login/login-module'
require './verify-phone/verify-phone-module'
require './facebook-sync/facebook-sync-module'
require './set-username/set-username-module'
require './request-push/request-push-module'

angular.module 'down', [
    'ionic'
    'down.login'
    'down.verifyPhone'
    'down.facebookSync'
    'down.setUsername'
    'down.requestPush'
  ]
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['Accept'] = 'application/json; version=1.2'
  .run ($ionicPlatform, $window) ->
    $ionicPlatform.ready ->
      # Hide the accessory bar by default (remove this to show the accessory bar
      # above the keyboard for form inputs)
      $window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar true
      $window.StatusBar?.styleDefault()
