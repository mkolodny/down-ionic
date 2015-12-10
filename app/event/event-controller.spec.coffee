require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
EventCtrl = require './event-controller'

describe 'event controller', ->
  commentsCount = null
  ctrl = null
  savedEvent = null

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $stateParams = angular.copy $injector.get('$stateParams')

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
  )

  it 'should set the saved event on the controller', ->
    expect(ctrl.savedEvent).toBe savedEvent

  it 'should set the comments count on the controller', ->
    expect(ctrl.commentsCount).toBe commentsCount
