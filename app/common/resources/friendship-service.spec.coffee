haversine = require 'haversine'

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
      isNearby: (user) ->
        if user.location is undefined or \
           @user.location is undefined
          return false

        start =
          latitude: @user.location.lat
          longitude: @user.location.long
        end =
          latitude: user.location.lat
          longitude: user.location.long
        haversine(start, end, {unit: 'mile'}) <= 5
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


  ##buildFriendItems
  describe 'building the friend items', ->
    friendItems = null
    nearbyFriends = null

    beforeEach ->
      # Mock the logged in user.
      Auth.user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pics/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535

      # Mock the user's friends.
      Auth.user.friends =
        2:
          id: 2
          email: 'ltorvalds@gmail.com'
          name: 'Linus Torvalds'
          username: 'valding'
          imageUrl: 'https://facebook.com/profile-pics/valding'
          location:
            lat: 40.7265834 # just under 5 mi away
            long: -73.9821535
        3:
          id: 3
          email: 'jclarke@gmail.com'
          name: 'Joan Clarke'
          username: 'jnasty'
          imageUrl: 'https://facebook.com/profile-pics/jnasty'
          location:
            lat: 40.7265834 # just under 5 mi away
            long: -73.9821535
        4:
          id: 4
          email: 'gvrossum@gmail.com'
          name: 'Guido van Rossum'
          username: 'vrawesome'
          imageUrl: 'https://facebook.com/profile-pics/vrawesome'
          location:
            lat: 40.79893 # just over 5 mi away
            long: -73.9821535
        5:
          id: 5
          name: '+19252852230'
      Auth.user.facebookFriends =
        4: Auth.user.friends[4]
      contacts =
        2: Auth.user.friends[2]
        3: Auth.user.friends[3]
      nearbyFriends = (friend for id, friend of Auth.user.friends \
          when Auth.isNearby friend)
      nearbyFriends.sort (a, b) ->
        if a.name.toLowerCase() < b.name.toLowerCase()
          return -1
        else
          return 1

    describe 'without a search query', ->

      # describe 'when the user has contacts', ->

      #   beforeEach ->
      #     ctrl.contacts = contacts
      #     ctrl.buildItems()

      #   it 'should set the items on the controller', ->
      #     items = [
      #       isDivider: true
      #       title: 'Nearby Friends'
      #     ]
      #     for friend in ctrl.nearbyFriends
      #       items.push
      #         isDivider: false
      #         friend: friend
      #     alphabeticalItems = [
      #       isDivider: true
      #       title: Auth.user.friends[4].name[0]
      #     ,
      #       isDivider: false
      #       friend: Auth.user.friends[4]
      #     ,
      #       isDivider: true
      #       title: Auth.user.friends[3].name[0]
      #     ,
      #       isDivider: false
      #       friend: Auth.user.friends[3]
      #     ,
      #       isDivider: true
      #       title: Auth.user.friends[2].name[0]
      #     ,
      #       isDivider: false
      #       friend: Auth.user.friends[2]
      #     ]
      #     for item in alphabeticalItems
      #       items.push item
      #     items.push
      #       isDivider: true
      #       title: 'Facebook Friends'
      #     facebookFriendsItems = [
      #       isDivider: false
      #       friend: Auth.user.facebookFriends[4]
      #     ]
      #     for item in facebookFriendsItems
      #       items.push item
      #     items.push
      #       isDivider: true
      #       title: 'Contacts'
      #     contactsItems = [
      #       isDivider: false
      #       friend: contacts[3]
      #     ,
      #       isDivider: false
      #       friend: contacts[2]
      #     ]
      #     for item in contactsItems
      #       items.push item
      #     expect(ctrl.items).toEqual items

      #   it 'should save a sorted array of nearby friends', ->
      #     expect(ctrl.nearbyFriends).toEqual [ # Alphabetical
      #       Auth.user.friends[3]
      #       Auth.user.friends[2]
      #     ]

      #   it 'should save nearby friend ids', ->
      #     nearbyFriendIds = {}
      #     nearbyFriendIds[2] = true
      #     nearbyFriendIds[3] = true
      #     expect(ctrl.nearbyFriendIds).toEqual nearbyFriendIds


      describe 'when not returning contacts', ->

        beforeEach ->
          friendItems = Friendship.buildFriendItems()

        it 'should set the items on the controller', ->
          items = [
            isDivider: true
            title: 'Nearby Friends'
          ]
          for friend in nearbyFriends
            items.push
              isDivider: false
              user: friend
          alphabeticalItems = [
            isDivider: true
            title: Auth.user.friends[4].name[0]
          ,
            isDivider: false
            user: Auth.user.friends[4]
          ,
            isDivider: true
            title: Auth.user.friends[3].name[0]
          ,
            isDivider: false
            user: Auth.user.friends[3]
          ,
            isDivider: true
            title: Auth.user.friends[2].name[0]
          ,
            isDivider: false
            user: Auth.user.friends[2]
          ]
          for item in alphabeticalItems
            items.push item
          items.push
            isDivider: true
            title: 'Facebook Friends'
          facebookFriendsItems = [
            isDivider: false
            user: Auth.user.facebookFriends[4]
          ]
          for item in facebookFriendsItems
            items.push item
          expect(friendItems).toEqual items


    describe 'with a search query', ->

      beforeEach ->
        options =
          query: 'U'

        friendItems = Friendship.buildFriendItems options

      it 'should build the items array', ->
        items = [
          isDivider: false
          user: Auth.user.friends[4]
        ,
          isDivider: false
          user: Auth.user.friends[2]
        ]
        expect(friendItems).toEqual items