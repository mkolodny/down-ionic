require 'angular'
require 'angular-local-storage'
require 'angular-ui-router'
require '../common/contacts/contacts-module'
require '../common/user-friendship-button/user-friendship-button-module'
require '../common/contact-friendship-button/contact-friendship-button-module'
AddFromAddressBookCtrl = require './add-from-address-book-controller'

angular.module 'down.addFromAddressBook', [
    'ui.router'
    'ionic'
    'down.contacts'
    'down.contactFriendshipButton'
    'down.userFriendshipButton'
    'LocalStorageModule'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFromAddressBook',
      url: '/add-from-address-book'
      templateUrl: 'app/add-from-address-book/add-from-address-book.html'
      controller: 'AddFromAddressBookCtrl as addFromAddressBook'
  .controller 'AddFromAddressBookCtrl', AddFromAddressBookCtrl
