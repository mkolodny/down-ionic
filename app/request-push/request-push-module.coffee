require 'angular'
require 'angular-ui-router'
require 'angular-local-storage'
require 'ng-cordova'
RequestPushCtrl = require './request-push-controller'

angular.module 'down.requestPush', [
    'ui.router'
    'ngCordova.plugins.push'
    'ngCordova.plugins.device'
    'LocalStorageModule'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestPush',
      url: '/push-notifications'
      templateUrl: 'app/request-push/request-push.html'
      controller: 'RequestPushCtrl as requestPush'
  .controller 'RequestPushCtrl', RequestPushCtrl
