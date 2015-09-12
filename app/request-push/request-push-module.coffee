require 'angular'
require 'angular-ui-router'
require 'angular-local-storage'
require '../common/push-notifications/push-notifications-module'
RequestPushCtrl = require './request-push-controller'

angular.module 'down.requestPush', [
    'ui.router'
    'LocalStorageModule'
    'down.pushNotifications'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestPush',
      url: '/push-notifications'
      templateUrl: 'app/request-push/request-push.html'
      controller: 'RequestPushCtrl as requestPush'
  .controller 'RequestPushCtrl', RequestPushCtrl
