require 'angular'
require 'angular-ui-router'
require 'ng-cordova'
RequestPushCtrl = require './request-push-controller'

angular.module 'down.requestPush', [
    'ui.router'
    'ngCordova.plugins.push'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestPush',
      url: '/push-notifications'
      templateUrl: '/app/request-push/request-push.html'
      controller: 'RequestPushCtrl as requestPush'
  .controller 'RequestPushCtrl', RequestPushCtrl
