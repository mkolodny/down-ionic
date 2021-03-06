require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
AddFriendsCtrl = require './add-friends-controller'

describe 'add friends controller', ->
  $state = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $state = $injector.get '$state'
    scope = $injector.get '$rootScope'

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


  describe 'tapping to add by phone', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addByPhone()

    it 'should go to the add by phone view', ->
      expect($state.go).toHaveBeenCalledWith 'addByPhone'
