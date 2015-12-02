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

  beforeEach angular.mock.module('rallytap.resources')

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


  describe 'sending a message', ->
    friend = null
    text = null
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

      # Mock the current time.
      jasmine.clock().install()
      currentDate = new Date 1438195002656
      jasmine.clock().mockDate currentDate

      Friendship.sendMessage friend, text

    afterEach ->
      jasmine.clock().uninstall()

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
        chatId: "#{Auth.user.id},#{friend.id}"
        type: 'text'
        createdAt: new Date()
      expect(Messages.insert).toHaveBeenCalledWith message


  describe 'getting a friend chat id', ->
    friendId = null
    chatId = null

    describe 'when the user\'s id is less than the friend\'s id', ->

      beforeEach ->
        Auth.user = {id: 1}
        friendId = 2
        chatId = Friendship.getChatId friendId

      it 'should return the user\'s id first', ->
        expect(chatId).toBe "#{Auth.user.id},#{friendId}"


    describe 'when the user\'s id is less than the friend\'s id', ->

      beforeEach ->
        Auth.user = {id: 2}
        friendId = 1
        chatId = Friendship.getChatId friendId

      it 'should return the friend\'s id first', ->
        expect(chatId).toBe "#{friendId},#{Auth.user.id}"


  describe 'getting a friend id from a chat id', ->
    friendId = null
    result = null

    beforeEach ->
      Auth.user = {id: 1}
      friendId = 2
      chatId = Friendship.getChatId friendId
      result = Friendship.parseChatId chatId

    it 'should return the friend id', ->
      expect(result).toBe "#{friendId}"