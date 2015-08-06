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

    it 'should return the serialized user', ->
      user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pic/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535
      expectedUser =
        id: user.id
        email: user.email
        name: user.name
        username: user.username
        image_url: user.imageUrl
        location:
          type: 'Point'
          coordinates: [user.location.lat, user.location.long]
      expect(User.serialize user).toEqual expectedUser


  describe 'deserializing a user', ->

    it 'should return the deserialized user', ->
      response =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        image_url: 'https://facebook.com/profile-pic/tdog'
        location:
          type: 'Point'
          coordinates: [40.7265834, -73.9821535]
      expectedUser =
        id: response.id
        email: response.email
        name: response.name
        username: response.username
        imageUrl: response.image_url
        location:
          lat: response.location.coordinates[0]
          long: response.location.coordinates[1]
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
        firebase_token: 'fdsa4321'
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
        firebaseToken: responseData.firebase_token
      , user
      expectedUser = new User(expectedUserData)
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

      expectedUser = new User(user)
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


  describe 'querying the user\'s friends', ->

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

      $httpBackend.expectGET "#{listUrl}/friends"
        .respond 200, angular.toJson(responseData)

      response = null
      User.getFriends()
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedUserData = User.deserialize responseData[0]
      expectedUsers = [new User expectedUserData]
      expect(response).toAngularEqual expectedUsers


  describe 'querying the user\'s facebook friends', ->

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

      $httpBackend.expectGET "#{listUrl}/facebook_friends"
        .respond 200, angular.toJson(responseData)

      response = null
      User.getFacebookFriends()
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedUserData = User.deserialize responseData[0]
      expectedUsers = [new User expectedUserData]
      expect(response).toAngularEqual expectedUsers
