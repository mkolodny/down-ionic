require '../common/contacts/contacts-module'
require '../common/friendship-button/friendship-button-module'
require '../common/local-db/local-db-module'
AddFromAddressBookCtrl = require './add-from-address-book-controller'

angular.module 'down.addFromAddressBook', [
    'ui.router'
    'ionic'
    'down.contacts'
    'down.friendshipButton'
    'down.localDB'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'addFromAddressBook',
      url: '/add-from-address-book'
      templateUrl: 'app/add-from-address-book/add-from-address-book.html'
      controller: 'AddFromAddressBookCtrl as addFromAddressBook'
  .controller 'AddFromAddressBookCtrl', AddFromAddressBookCtrl
