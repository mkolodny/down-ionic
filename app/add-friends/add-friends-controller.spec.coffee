require 'angular'
require 'angular-mocks'
require 'angular-ui-router'

AddFriendsCtrl = require './add-friends-controller'

describe 'add friends controller', ->
  ctrl = null
  scope = null
  $state = null

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new true

    ctrl = $controller AddFriendsCtrl,
      $scope: scope
  )

  describe 'tapping to add by username', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addByUsername()

    it 'should go to the add by username view', ->
      expect($state.go).toHaveBeenCalledWith 'addByUsername'


  describe 'tapping to add from address book', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromAddressBook()

    it 'should go to the add from address book view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromAddressBook'


  describe 'tapping to add from facebook', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromFacebook()

    it 'should go to the add from facebook view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromFacebook'
