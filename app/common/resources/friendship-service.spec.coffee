require 'angular'
require 'angular-mocks'
require '../meteor/meteor-mocks'
require './resources-module'

describe 'friendship service', ->
  $httpBackend = null
  Auth = null
  Friendship = null
  listUrl = null
  $meteor = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module(($provide) ->
    Auth =
      user:
        id: 1
        friends: {}
      setUser: jasmine.createSpy 'Auth.setUser'
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    Friendship = $injector.get 'Friendship'
    $meteor = $injector.get '$meteor'

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
      expectedFriendship = new Friendship expectedFriendshipData
      expect(response).toAngularEqual expectedFriendship


  describe 'deleting with a friend', ->
    friendId = null
    url = null
    requestData = null
    checkHeaders = null

    beforeEach ->
      friendId = 1
      url = "#{listUrl}/friend"
      requestData = {friend: friendId}
      checkHeaders = (headers) ->
        headers['Content-Type'] is 'application/json;charset=utf-8'

    describe 'successfully', ->
      deleted = null

      beforeEach ->
        $httpBackend.expect 'DELETE', url, requestData, checkHeaders
          .respond 200, null

        deleted = false
        Friendship.deleteWithFriendId friendId
          .$promise.then ->
            deleted = true
        $httpBackend.flush 1

      it 'should DELETE the friendship', ->
        expect(deleted).toBe true


    describe 'with an error', ->
      rejected = null

      beforeEach ->
        $httpBackend.expect 'DELETE', url, requestData, checkHeaders
          .respond 500, null

        rejected = false
        Friendship.deleteWithFriendId friendId
          .$promise.then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


  describe 'acknowledging', ->
    friendId = null
    url = null
    requestData = null

    beforeEach ->
      friendId = 1
      url = "#{listUrl}/ack"
      requestData = {friend: friendId}

    describe 'successfully', ->
      updated = null

      beforeEach ->
        $httpBackend.expectPUT url, requestData
          .respond 200, null

        updated = false
        Friendship.ack {friend: friendId}
          .$promise.then ->
            updated = true
        $httpBackend.flush 1

      it 'should update the friendship', ->
        expect(updated).toBe true


    describe 'with an error', ->
      rejected = null

      beforeEach ->
        $httpBackend.expectPUT url, requestData
          .respond 500, null

        rejected = false
        Friendship.ack {friend: friendId}
          .$promise.then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


  describe 'sending a message', ->
    friend = null
    text = null
    url = null
    requestData = null
    Messages = null

    beforeEach ->
      # Mock the mongo messages collection.
      Messages =
        insert: jasmine.createSpy 'Messages.insert'
      $meteor.getCollectionByName.and.returnValue Messages

      Auth.user =
        id: 1
        name: 'Ice Cube'
        firstName: 'Ice'
        lastName: 'Cube'
        username: 'cube'
        imageUrl: 'https://facebook.com/profile-pics/easye'
      friend =
        id: 2
        name: 'Easy E'
        firstName: 'Easy'
        lastName: 'E'
        username: 'easye'
        imageUrl: 'https://facebook.com/profile-pics/easye'
      text = 'I\'m in love with a robot.'
      url = "#{listUrl}/#{friend.id}/messages"
      requestData = {text: text}

    describe 'successfully', ->
      resolved = false

      beforeEach ->
        # Mock the current time.
        jasmine.clock().install()
        currentDate = new Date 1438195002656
        jasmine.clock().mockDate currentDate

        $httpBackend.expectPOST url, requestData
          .respond 201, null

        Friendship.sendMessage friend.id, text
          .then ->
            resolved = true
        $httpBackend.flush 1

      afterEach ->
        jasmine.clock().uninstall()

      it 'should resolve the promise', ->
        expect(resolved).toBe true

      it 'should get the eventMessages collection', ->
        expect($meteor.getCollectionByName).toHaveBeenCalledWith 'messages'

      it 'should save the message in the meteor server', ->
        message =
          creator:
            id: "#{Auth.user.id}"
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: text
          groupId: "#{Auth.user.id},#{friend.id}"
          type: 'text'
          createdAt: new Date()
        expect(Messages.insert).toHaveBeenCalledWith message


    describe 'unsuccessfully', ->
      rejected = false

      beforeEach ->
        $httpBackend.expectPOST url, requestData
          .respond 500, null

        Friendship.sendMessage friend.id, text
          .then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true
