require 'angular'
require 'angular-mocks'
require 'ng-cordova'
RequestPushCtrl = require './request-push-controller'

describe 'request push controller', ->
  $state = null
  scope = null
  ctrl = null

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()

    ctrl = $controller RequestPushCtrl,
      $scope: scope
  )

  describe 'requesting push notifications permission', ->

    # should it be hasRequestedPushNotifications?
    # the flag represents whether or not the promt has been shown yet
    it 'should set localStorage.hasAllowedPushNotifications to true', -> 

    describe 'permission granted', ->

      it 'should save the token to the database', ->

        describe 'sucessfully', ->

          it 'should send the user to the request contacts view', ->

        describe 'save failed', ->

          it 'should show an error', ->

    describe 'permission denied', ->

      it 'should send the user to the request contacts view', ->
