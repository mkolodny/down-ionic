require 'angular'
require 'angular-mocks'
AddFromAddressBookCtrl = require './add-from-address-book-controller'

describe 'add from address book controller', ->
  ctrl = null
  scope = null

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'

    ctrl = $controller AddFromAddressBookCtrl,
      $scope: scope
  )
