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


  describe 'syncing with facebook', ->
    fbSyncUrl = null
    postData = null

    beforeEach ->
      fbSyncUrl = "#{apiRoot}/social-account"
      postData = access_token: 'poiu0987'

    describe 'on success', ->
      responseData = null
      response = null

      beforeEach ->
        Auth.user =
          id: 1
          location:
            lat: 40.7265834
            long: -73.9821535
          authtoken: 'fdsa4321'
          firebaseToken: 'qwer6789'
        responseData =
          id: Auth.user.id
          email: 'aturing@gmail.com'
          name: 'Alan Turing'
          image_url: 'https://facebook.com/profile-pic/tdog'
          location:
            type: 'Point'
            coordinates: [Auth.user.lat, Auth.user.long]
        $httpBackend.expectPOST fbSyncUrl, postData
          .respond 201, responseData

        Auth.syncWithFacebook(postData).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should return the user', ->
        expectedUserData = angular.extend
          email: responseData.email
          name: responseData.name
          imageUrl: responseData.image_url
        , Auth.user
        expectedUser = new User(expectedUserData)
        expect(response).toAngularEqual expectedUser

      it 'should update the logged in user', ->
        expect(Auth.user).toBe response


    describe 'on error', ->

      it 'should reject the promise', ->
        $httpBackend.expectPOST fbSyncUrl, postData
          .respond 500, null

        rejected = false
        Auth.syncWithFacebook(postData).then (->), ->
          rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true


  describe 'sending a verification text', ->
    verifyPhoneUrl = null
    phone = null
    postData = null

    beforeEach ->
      verifyPhoneUrl = "#{apiRoot}/authcodes"
      phone = '+1234567890'
      postData = {phone: phone}

    describe 'on success', ->

      it 'should resolve the promise', ->
        $httpBackend.expectPOST verifyPhoneUrl, postData
          .respond 200, null

        resolved = false
        Auth.sendVerificationText(phone).then ->
          resolved = true
        $httpBackend.flush 1

        expect(resolved).toBe true


    describe 'on error', ->

      it 'should reject the promise', ->
        $httpBackend.expectPOST verifyPhoneUrl, postData
          .respond 500, null

        rejected = false
        Auth.sendVerificationText(phone).then (->), ->
          rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true
