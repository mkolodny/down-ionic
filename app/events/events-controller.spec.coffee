require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/meteor/meteor-mocks'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $q = null
  $state = null
  $meteor = null
  Auth = null
  commentsCollection = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $meteor = $injector.get '$meteor'
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'

    # Mock the current user.
    Auth.currentUser = {id: 1}

    commentsCollection = 'commentsCollection'
    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'comments' then return commentsCollection

    ctrl = $controller EventsCtrl,
      $scope: scope
  )

  it 'should set the comments collection on the controller', ->
    expect(ctrl.Comments).toBe commentsCollection

  ##getCommentsCount
  