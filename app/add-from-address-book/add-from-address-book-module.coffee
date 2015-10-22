require '../common/contacts/contacts-module'
require '../common/friendship-button/friendship-button-module'
require '../common/local-db/local-db-module'
AddFromAddressBookCtrl = require './add-from-address-book-controller'

angular.module 'rallytap.addFromAddressBook', [
    'ui.router'
    'ionic'
    'rallytap.contacts'
    'rallytap.friendshipButton'
    'rallytap.localDB'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFromAddressBook',
      url: '/add-from-address-book'
      templateUrl: 'app/add-from-address-book/add-from-address-book.html'
      controller: 'AddFromAddressBookCtrl as addFromAddressBook'
  .controller 'AddFromAddressBookCtrl', AddFromAddressBookCtrl
