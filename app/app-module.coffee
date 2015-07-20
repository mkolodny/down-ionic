require 'angular'
require './login/login-module'

angular.module 'down', ['ionic', 'down.login']
  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['Accept'] = 'application/json; version=1.2'
  .run ($ionicPlatform, $window) ->
    $ionicPlatform.ready ->
      # Hide the accessory bar by default (remove this to show the accessory bar
      # above the keyboard for form inputs)
      $window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar true
      $window.StatusBar?.styleDefault()
