require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
EventCtrl = require './event-controller'

describe 'event controller', ->
  $rootScope = null
  commentsCount = null
  ctrl = null
  savedEvent = null
  scope = null

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $stateParams = angular.copy $injector.get('$stateParams')
    $rootScope = $injector.get '$rootScope'
    scope = $rootScope

    savedEvent =
      id: 1
      eventId: 2
      event:
        id: 2
    commentsCount = 16
    $stateParams.savedEvent = savedEvent
    $stateParams.commentsCount = commentsCount

    ctrl = $controller EventCtrl,
      $stateParams: $stateParams
      $scope: scope
  )

  it 'should set the saved event on the controller', ->
    expect(ctrl.savedEvent).toBe savedEvent

  it 'should set the comments count on the controller', ->
    expect(ctrl.commentsCount).toBe commentsCount


  ##$ionicView.beforeEnter
  describe 'when the view enters', ->

    beforeEach ->
      $rootScope.$broadcast '$ionicView.beforeEnter'
      $rootScope.$apply()

    it 'should hide the tab bar', ->
      expect($rootScope.hideTabBar).toBe true


