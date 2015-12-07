require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
require '../common/mixpanel/mixpanel-module'
CommentsCtrl = require './comments-controller'

describe 'comments controller', ->
  $q = null
  $state = null
  $stateParams = null
  $meteor = null
  $mixpanel = null
  Auth = null
  commentsCollection = null
  ctrl = null
  event = null
  scope = null
  User = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $stateParams = angular.copy $injector.get('$stateParams')
    $meteor = $injector.get '$meteor'
    $mixpanel = $injector.get '$mixpanel'
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'
    User = $injector.get 'User'

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

    ctrl = $controller CommentsCtrl,
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
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      scope.$meteorSubscribe = jasmine.createSpy('scope.$meteorSubscribe') \
        .and.returnValue deferred.promise

      comments = [
        _id: '1'
        creator:
          id: 1
      ]
      scope.$meteorCollection = jasmine.createSpy('scope.$meteorCollection') \
        .and.returnValue comments

      scope.$emit '$ionicView.beforeEnter'
      scope.$apply()

    it 'should subscribe to the event comments', ->
      expect(scope.$meteorSubscribe).toHaveBeenCalledWith('comments',
          "#{ctrl.event.id}")

    it 'should bind the comments to the controller', ->
      expect(scope.$meteorCollection).toHaveBeenCalledWith ctrl.getComments, false

    describe 'when comment subscription is ready', ->

      beforeEach ->
        deferred.resolve()
        scope.$apply()

      it 'should set a comment loaded flag', ->
        expect(ctrl.commentsLoaded).toBe true


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
        transform: ctrl.transformComment
      expect(ctrl.Comments.find).toHaveBeenCalledWith selector, options


  ##postComment
  describe 'posting a comment', ->
    commentText = null

    beforeEach ->
      jasmine.clock().install()
      date = new Date 1438014089235
      jasmine.clock().mockDate date

      spyOn $mixpanel, 'track'

      ctrl.Comments =
        insert: jasmine.createSpy 'Comments.insert'
      commentText = 'Some comment text'
      ctrl.newComment = commentText
      ctrl.comments = []

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

    it 'should track in mixpanel', ->
      expect($mixpanel.track).toHaveBeenCalledWith 'Post Comment',
        'comments count': ctrl.comments.length


  ##transformComment
  describe 'transforming a comment', ->
    comment = null
    transformedComment = null

    beforeEach ->
      comment =
        _id: '1'
        creator:
          id: '1'

      transformedComment = ctrl.transformComment comment

    it 'should return the comment with the creator as a user', ->
      expect(transformedComment.creator).toEqual jasmine.any(User)
