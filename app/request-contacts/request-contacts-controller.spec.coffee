require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
RequestContactsCtrl = require './request-contacts-controller'

describe 'request contacts controller', ->
  $state = null
  ctrl = null

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $state = $injector.get '$state'
    ctrl = $controller RequestContactsCtrl
  )

  describe 'tapping continue', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.requestContacts()

    it 'should direct to find friends view', ->
      expect($state.go).toHaveBeenCalledWith 'findFriends'