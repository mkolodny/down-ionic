require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'user service', ->
  $httpBackend = null
  User = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    User = $injector.get 'User'

    listUrl = "#{apiRoot}/users"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'should have a list url', ->
    expect(User.listUrl).toBe listUrl

  describe 'serializing a user', ->
    user = null

    beforeEach ->
      user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        firstName: 'Alan'
        lastName: 'Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pic/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535

    describe 'when the user has all possible attributes', ->

      it 'should return the serialized user', ->
        expectedUser =
          id: user.id
          email: user.email
          name: user.name
          first_name: user.firstName
          last_name: user.lastName
          username: user.username
          image_url: user.imageUrl
          location:
            type: 'Point'
            coordinates: [user.location.lat, user.location.long]
        expect(User.serialize user).toEqual expectedUser


    describe 'when the user has the min attributes', ->

      beforeEach ->
        delete user.location
        delete user.firstName
        delete user.lastName

      it 'should return the serialized user', ->
        expectedUser =
          id: user.id
          email: user.email
          name: user.name
          username: user.username
          image_url: user.imageUrl
        expect(User.serialize user).toEqual expectedUser


  describe 'deserializing a user', ->
    response = null

    beforeEach ->
      response =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        first_name: 'Alan'
        last_name: 'Turing'
        username: 'tdog'
        image_url: 'https://facebook.com/profile-pic/tdog'
        location:
          type: 'Point'
          coordinates: [40.7265834, -73.9821535]

    describe 'when the user is a friend', ->

      it 'should return the deserialized user', ->
        expectedUser = new User
          id: response.id
          email: response.email
          name: response.name
          firstName: response.first_name
          lastName: response.last_name
          username: response.username
          imageUrl: response.image_url
          location:
            lat: response.location.coordinates[0]
            long: response.location.coordinates[1]
        expect(User.deserialize response).toEqual expectedUser


    describe 'when the user has the min attributes', ->

      beforeEach ->
        response.location = null
        response.first_name = null
        response.last_name = null

      it 'should return the deserialized user', ->
        expectedUser = new User
          id: response.id
          email: response.email
          name: response.name
          username: response.username
          imageUrl: response.image_url
        expect(User.deserialize response).toEqual expectedUser


    describe 'when the user is the current user', ->
      friend = null

      beforeEach ->
        friend =
          id: 2
          email: 'jclarke@gmail.com'
          name: 'Joan Clarke'
          first_name: 'Joan'
          last_name: 'Clarke'
          username: 'jmamba'
          image_url: 'http://imgur.com/jcke'
          location:
            type: 'Point'
            coordinates: [40.7265836, -73.9821539]
        response = angular.extend response,
          friends: [friend]
          facebook_friends: [friend]

      it 'should return the deserialized user', ->
        expectedFriend = new User
          id: friend.id
          email: friend.email
          name: friend.name
          firstName: friend.first_name
          lastName: friend.last_name
          username: friend.username
          imageUrl: friend.image_url
          location:
            lat: friend.location.coordinates[0]
            long: friend.location.coordinates[1]
        friends = {}
        friends[expectedFriend.id] = expectedFriend
        facebookFriends = {}
        facebookFriends[expectedFriend.id] = expectedFriend
        expectedUser = new User
          id: response.id
          email: response.email
          name: response.name
          firstName: response.first_name
          lastName: response.last_name
          username: response.username
          imageUrl: response.image_url
          location:
            lat: response.location.coordinates[0]
            long: response.location.coordinates[1]
          friends: friends
          facebookFriends: facebookFriends
        expect(User.deserialize response).toEqual expectedUser


  describe 'creating', ->

    it 'should POST the user', ->
      user =
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pic/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535
      postData = User.serialize user
      responseData = angular.extend
        id: 1
        authtoken: 'asdf1234'
      , postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      User.save user
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedUserData = angular.extend
        id: responseData.id
        authtoken: responseData.authtoken
      , user
      expectedUser = new User expectedUserData
      expect(response).toAngularEqual expectedUser


  describe 'updating', ->

    it 'should PUT the user', ->
      user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pic/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535
      postData = User.serialize user
      responseData = postData

      url = "#{listUrl}/#{user.id}"
      $httpBackend.expectPUT url, postData
        .respond 200, angular.toJson(responseData)

      response = null
      User.update user
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedUser = new User user
      expect(response).toAngularEqual expectedUser


  describe 'getting', ->

    it 'should GET the user', ->
      responseData =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        image_url: 'https://facebook.com/profile-pic/tdog'
        location:
          type: 'Point'
          coordinates: [40.7265834, -73.9821535]

      detailUrl = "#{listUrl}/#{responseData.id}"
      $httpBackend.expectGET detailUrl
        .respond 200, angular.toJson(responseData)

      response = null
      User.get {id: responseData.id}
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedUserData = User.deserialize responseData
      expectedUser = new User expectedUserData
      expect(response).toAngularEqual expectedUser


  describe 'querying', ->

    it 'should GET the users', ->
      responseData = [
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        image_url: 'https://facebook.com/profile-pic/tdog'
        location:
          type: 'Point'
          coordinates: [40.7265834, -73.9821535]
      ]

      $httpBackend.expectGET listUrl
        .respond 200, angular.toJson(responseData)

      response = null
      User.query()
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedUserData = User.deserialize responseData[0]
      expectedUsers = [new User expectedUserData]
      expect(response).toAngularEqual expectedUsers


  describe 'checking if a username is available', ->
    username = null
    testUsernameUrl = null

    beforeEach ->
      username = 'tdog'
      testUsernameUrl = "#{listUrl}/username/#{username}"

    describe 'when the username is available', ->

      it 'should return true', ->
        $httpBackend.expectGET testUsernameUrl
          .respond 404, null

        result = null
        User.isUsernameAvailable username
          .then (_result_) ->
            result = _result_
        $httpBackend.flush 1

        expect(result).toBe true


    describe 'when the username is taken', ->

      it 'should return false', ->
        $httpBackend.expectGET testUsernameUrl
          .respond 200, null

        result = null
        User.isUsernameAvailable username
          .then (_result_) ->
            result = _result_
        $httpBackend.flush 1

        expect(result).toBe false


    describe 'when the request fails', ->

      it 'should reject the promise', ->
        $httpBackend.expectGET testUsernameUrl
          .respond 500, null

        rejected = false
        User.isUsernameAvailable username
          .then null, ->
            rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true


  describe 'getting a user\'s imageUrl', ->
    user = null
    imageUrl = null

    beforeEach ->
      user = new User
        id: 1
        imageUrl: 'https://facebook.com/profile-pic/tdog'

    describe 'without a size', ->

      beforeEach ->
        imageUrl = user.getImageUrl()

      it 'should return the default size', ->
        defaultSize = 100
        expected = "#{user.imageUrl}?width=#{defaultSize}&height=#{defaultSize}"
        expect(imageUrl).toBe expected


    describe 'with a size', ->
      size = null

      beforeEach ->
        size = 30
        imageUrl = user.getImageUrl size

      it 'should return the default size', ->
        expected = "#{user.imageUrl}?width=#{size}&height=#{size}"
        expect(imageUrl).toBe expected
