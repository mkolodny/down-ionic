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
      postData =
        email: user.email
        name: user.name
        username: user.username
        image_url: user.imageUrl
        location:
          type: 'Point'
          coordinates: [user.location.lat, user.location.long]
      responseData = angular.extend
        id: 1
        authtoken: 'asdf1234'
        firebase_token: 'fdsa4321'
      , postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      User.save(user).$promise.then (_response_) ->
        response = _response_
      $httpBackend.flush 1

      expectedUserData = angular.extend
        id: responseData.id
        authtoken: responseData.authtoken
        firebaseToken: responseData.firebase_token
      , user
      expectedUser = new User(expectedUserData)
      expect(response).toAngularEqual expectedUser
