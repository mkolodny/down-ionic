require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
AddFriendsSignupCtrl = require './add-friends-signup-controller'

describe 'add friends during signup controller', ->
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    scope = $rootScope.$new true

    ctrl = $controller AddFriendsSignupCtrl,
      Auth: Auth
      $scope: scope
  )

  describe 'finishing', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.done()

    it 'should go to the events view', ->
      expect($state.go).toHaveBeenCalledWith 'events'
