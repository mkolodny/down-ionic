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

      expectedFriendship = new Friendship
        id: responseData.id
        userId: responseData.user
        friendId: responseData.friend
      actualFriendship = new Friendship(response)
      expect(actualFriendship).toAngularEqual expectedFriendship


  xdescribe 'deleting with a friend', ->

    it 'should DELETE the friendship', ->
      deleteData = friend: 1
      url = "#{listUrl}/friend"

      $httpBackend.expectDELETE url, deleteData
        .respond 200, null

      Friendship.deleteWithFriend deleteData
      $httpBackend.flush 1
