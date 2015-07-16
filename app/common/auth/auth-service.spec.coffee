require 'angular-mocks'
require './auth-module'

describe 'Auth service', ->
  $httpBackend = null
  apiRoot = null
  Auth = null
  User = null

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    Auth = angular.copy $injector.get('Auth')
    User = $injector.get 'User'
  )

  it 'should init the user', ->
    expect(Auth.user).toEqual {}

  describe 'checking whether the user is authenticated', ->
    testAuthUrl = null

    beforeEach ->
      testAuthUrl = "#{apiRoot}/users/me"

    describe 'when the user is authenticated', ->

      it 'should return true', ->
        $httpBackend.expectGET testAuthUrl
          .respond 200, null

        result = null
        Auth.isAuthenticated().then (_result_) ->
          result = _result_
        $httpBackend.flush 1

        expect(result).toBe true


    describe 'when the user is not authenticated', ->

      it 'should return false', ->
        $httpBackend.expectGET testAuthUrl
          .respond 401, null

        result = null
        Auth.isAuthenticated().then (_result_) ->
          result = _result_
        $httpBackend.flush 1

        expect(result).toBe false


    describe 'when the request fails', ->

      it 'should reject the promise', ->
        $httpBackend.expectGET testAuthUrl
          .respond 500, null

        rejected = false
        Auth.isAuthenticated().then (->), ->
          rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true


  describe 'authenticating', ->
    authenticateUrl = null
    postData = null

    beforeEach ->
      authenticateUrl = "#{apiRoot}/sessions"
      postData =
        code: 'asdf1234'
        phone: '+1234567890'

    describe 'when the request succeeds', ->
      responseData = null
      response = null

      beforeEach ->
        responseData =
          id: 1
          email: 'aturing@gmail.com'
          name: 'Alan Turing'
          username: 'tdog'
          image_url: 'https://facebook.com/profile-pic/tdog'
          location:
            type: 'Point'
            coordinates: [40.7265834, -73.9821535]
          authtoken: 'fdsa4321'
          firebaseToken: 'qwer6789'
        $httpBackend.expectPOST authenticateUrl, postData
          .respond 200, responseData

        Auth.authenticate(postData).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should get or create the user', ->
        expectedUserData = User.deserialize responseData
        expectedUser = new User expectedUserData
        expect(response).toAngularEqual expectedUser

      it 'should set the returned user on the Auth object', ->
        expect(Auth.user).toBe response


    describe 'when the request fails', ->

      it 'should reject the promise', ->
        $httpBackend.expectPOST authenticateUrl, postData
          .respond 500, null

        rejected = false
        Auth.authenticate(postData).then (->), ->
          rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true
