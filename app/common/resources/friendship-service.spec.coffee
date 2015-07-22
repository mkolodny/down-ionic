require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'friendship service', ->
  $httpBackend = null
  Friendship = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

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

    it 'should POST the friendship', ->
      friendship =
        userId: 1
        friendId: 2
      postData =
        user: friendship.userId
        friend: friendship.friendId
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      Friendship.save(friendship).$promise.then (_response_) ->
        response = _response_
      $httpBackend.flush 1

      expectedFriendshipData = angular.extend {id: responseData.id}, friendship
      expectedFriendship = new Friendship(expectedFriendshipData)
      expect(response).toAngularEqual expectedFriendship


  describe 'deleting with a friend', ->

    it 'should DELETE the friendship', ->
      friendId = 1
      url = "#{listUrl}/friend"
      deleteData = friend: friendId
      checkHeaders = (headers) ->
        headers['Content-Type'] is 'application/json;charset=utf-8'

      $httpBackend.expect 'DELETE', url, deleteData, checkHeaders
        .respond 200, null

      deleted = false
      Friendship.deleteWithFriendId(friendId).then ->
        deleted = true
      $httpBackend.flush 1

      expect(deleted).toBe true
