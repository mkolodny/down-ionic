require 'angular'
require 'angular-ui-router'
RequestContactsCtrl = require './request-contacts-controller'

angular.module 'down.requestContacts', [
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'requestContacts',
      url: '/address-book'
      templateUrl: 'app/request-contacts/request-contacts.html'
      controller: 'RequestContactsCtrl as requestContacts'
  .controller 'RequestContactsCtrl', RequestContactsCtrl
