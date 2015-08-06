require 'angular'
require 'angular-ui-router'
require 'ng-cordova'
RequestContactsCtrl = require './request-contacts-controller'

angular.module 'down.requestContacts', [
    'ui.router'
    'ngCordova'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestContacts',
      url: '/address-book'
      templateUrl: 'app/request-contacts/request-contacts.html'
      controller: 'RequestContactsCtrl as requestContacts'
  .controller 'RequestContactsCtrl', RequestContactsCtrl
