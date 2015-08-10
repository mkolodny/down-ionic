require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'friendship service', ->
  $httpBackend = null
  Auth = null
  Friendship = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module(($provide) ->
    Auth =
      user:
        id: 1
        friends: {}
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    Friendship = $injector.get 'Friendship'

    listUrl = "#{apiRoot}/friendships"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'creating', ->
    friendId = null
    friendship = null
    responseData = null
    response = null

    beforeEach ->
      friendId = 2
      friendship =
        userId: 1
        friendId: friendId
      postData =
        user: friendship.userId
        friend: friendship.friendId
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      Friendship.save friendship
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

    it 'should POST the friendship', ->
      expectedFriendshipData = angular.extend {id: responseData.id}, friendship
      expectedFriendship = new Friendship(expectedFriendshipData)
      expect(response).toAngularEqual expectedFriendship

    it 'should add the friend to Auth', ->
      expect(Auth.user.friends[friendId]).toBe true


  describe 'deleting with a friend', ->
    friendId = null
    url = null
    deleteData = null
    checkHeaders = null

    beforeEach ->
      friendId = 1
      url = "#{listUrl}/friend"
      deleteData = friend: friendId
      checkHeaders = (headers) ->
        headers['Content-Type'] is 'application/json;charset=utf-8'

    describe 'successfully', ->
      deleted = false

      beforeEach ->
        $httpBackend.expect 'DELETE', url, deleteData, checkHeaders
          .respond 200, null

        # Set the user as a friend on Auth.
        Auth.user.friends[friendId] = true

        Friendship.deleteWithFriendId friendId
          .then ->
            deleted = true
        $httpBackend.flush 1

      it 'should DELETE the friendship', ->
        expect(deleted).toBe true

      it 'should remove the friend from Auth', ->
        expect(Auth.user.friends[friendId]).not.toBeDefined()


    describe 'with an error', ->
      rejected = false

      beforeEach ->
        $httpBackend.expect 'DELETE', url, deleteData, checkHeaders
          .respond 500, null

        Friendship.deleteWithFriendId friendId
          .then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true
