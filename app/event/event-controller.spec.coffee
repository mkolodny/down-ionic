require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
EventCtrl = require './event-controller'

describe 'event controller', ->
  $q = null
  $state = null
  $stateParams = null
  $meteor = null
  Auth = null
  commentsCollection = null
  ctrl = null
  event = null
  scope = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $stateParams = angular.copy $injector.get('$stateParams')
    $meteor = $injector.get '$meteor'
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'

    # Mock the current user.
    Auth.user = 
      id: 1
      name: 'Andrew Linfoot'
      firstName: 'Andrew'
      lastName: 'Linfoot'
      imageUrl: 'http://someimageurl.com'

    event =
      id: 1
      title: 'Bars?!?!'
      datetime: new Date()
      place:
        name: 'B Bar & Grill'
        lat: 40.7270718
        long: -73.9919324
      createdAt: new Date()
    $stateParams.event = event

    commentsCollection = 'commentsCollection'
    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'comments' then return commentsCollection

    ctrl = $controller EventCtrl,
      $scope: scope
      $stateParams: $stateParams
  )

  it 'should set the comments collection on the controller', ->
    expect(ctrl.Comments).toBe commentsCollection

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  ##$ionicView.beforeEnter
  describe 'before the view enters', ->
    comments = null

    beforeEach ->
      scope.$meteorSubscribe = jasmine.createSpy 'scope.$meteorSubscribe'

      comments = []
      scope.$meteorCollection = jasmine.createSpy('scope.$meteorCollection') \
        .and.returnValue comments

      scope.$emit '$ionicView.beforeEnter'
      scope.$apply()

    it 'should subscribe to the event comments', ->
      expect(scope.$meteorSubscribe).toHaveBeenCalledWith 'comments', "#{ctrl.event.id}"

    it 'should bind the comments to the controller', ->
      expect(scope.$meteorCollection).toHaveBeenCalledWith ctrl.getComments, false


  ##getComments
  describe 'getting the comments for the event', ->
    cursor = null
    result = null

    beforeEach ->
      cursor = 'some cursor'
      ctrl.Comments =
        find: jasmine.createSpy('Comments.find').and.returnValue cursor

      result = ctrl.getComments()

    it 'should return the cursor', ->
      expect(result).toBe cursor

    it 'should filter and sort comments by event', ->
      selector =
        eventId: "#{ctrl.event.id}"
      options =
        sort:
          createdAt: 1
      expect(ctrl.Comments.find).toHaveBeenCalledWith selector, options


  ##postComment
  describe 'posting a comment', ->
    commentText = null

    beforeEach ->
      jasmine.clock().install()
      date = new Date 1438014089235
      jasmine.clock().mockDate date

      ctrl.Comments =
        insert: jasmine.createSpy 'Comments.insert'
      commentText = 'Some comment text'
      ctrl.newComment = commentText

      ctrl.postComment()

    afterEach ->
      jasmine.clock().uninstall()

    it 'should insert a new comment', ->
      expect(ctrl.Comments.insert).toHaveBeenCalledWith
        creator:
          id: "#{Auth.user.id}"
          name: Auth.user.name
          firstName: Auth.user.firstName
          lastName: Auth.user.lastName
          imageUrl: Auth.user.imageUrl
        eventId: "#{ctrl.event.id}"
        createdAt: new Date()
        text: commentText

    it 'should clear the new comment field', ->
      expect(ctrl.newComment).toBeNull()  
