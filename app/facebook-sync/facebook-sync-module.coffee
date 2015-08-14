require 'angular'
require 'angular-ui-router'
require 'ng-cordova-oauth/dist/ng-cordova-oauth.js'
FacebookSyncCtrl = require './facebook-sync-controller'

angular.module 'down.facebookSync', [
    'ui.router'
    'ngCordovaOauth'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'facebookSync',
      url: '/fb-sync'
      templateUrl: 'app/facebook-sync/facebook-sync.html'
      controller: 'FacebookSyncCtrl as fbSync'
  .controller 'FacebookSyncCtrl', FacebookSyncCtrl
  .value 'fbClientId', '864552050271610' # staging
