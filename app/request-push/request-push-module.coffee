require '../common/push-notifications/push-notifications-module'
require '../common/auth/auth-module'
RequestPushCtrl = require './request-push-controller'

angular.module 'down.requestPush', [
    'ui.router'
    'down.pushNotifications'
    'down.auth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestPush',
      url: '/push-notifications'
      templateUrl: 'app/request-push/request-push.html'
      controller: 'RequestPushCtrl as requestPush'
  .controller 'RequestPushCtrl', RequestPushCtrl
