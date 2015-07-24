require 'angular-mocks'
require 'angular-ui-router'
require 'ng-cordova'
require './auth-module'

describe 'Auth service', ->
  $cordovaGeolocation = null
  $httpBackend = null
  scope = null
  $state = null
  $q = null
  apiRoot = null
  Auth = null
  User = null
  userDeserialize = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ngCordova.plugins.geolocation')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module(($provide) ->

    $cordovaGeolocation =
      watchPosition: jasmine.createSpy('$cordovaGeolocation.watchPosition') 
    $provide.value '$cordovaGeolocation', $cordovaGeolocation

    userDeserialize = 'userDeserialize'

    User =
      update: jasmine.createSpy('User.update')
      deserialize: jasmine.createSpy('User.deserialize').and.returnValue userDeserialize
    $provide.value 'User', User

    $state = 
      go: jasmine.createSpy('$state.go')
    $provide.value '$state', $state

    return
  )

  beforeEach inject(($injector) ->
    $q = $injector.get '$q'
    $httpBackend = $injector.get '$httpBackend'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    apiRoot = $injector.get 'apiRoot'
    Auth = angular.copy $injector.get('Auth')
    scope = $rootScope.$new()
  )

  it 'should init the user', ->
    expect(Auth.user).toEqual {}

  it 'should init the user\'s friends', ->
    expect(Auth.friends).toEqual {}

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
    code = null
    phone = null
    postData = null

    beforeEach ->
      authenticateUrl = "#{apiRoot}/sessions"
      phone = '+1234567890'
      code = 'asdf1234'
      postData =
        phone: phone
        code: code

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

        Auth.authenticate(phone, code).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should call deserialize with response data', ->
        expect(User.deserialize).toHaveBeenCalledWith responseData
        expect(User.deserialize.calls.count()).toBe 1

      it 'should get or create the user', ->
        expect(response).toAngularEqual userDeserialize

      it 'should set the returned user on the Auth object', ->
        expect(Auth.user).toBe userDeserialize

    describe 'when the request fails', ->

      it 'should reject the promise', ->
        status = 500
        $httpBackend.expectPOST authenticateUrl, postData
          .respond status, null

        rejectedStatus = null
        Auth.authenticate(phone, code).then (->), (_status_) ->
          rejectedStatus = _status_
        $httpBackend.flush 1

        expect(rejectedStatus).toEqual status


  describe 'syncing with facebook', ->
    fbSyncUrl = null
    accessToken = null
    postData = null

    beforeEach ->
      fbSyncUrl = "#{apiRoot}/social-account"
      accessToken = 'poiu0987'
      postData = access_token: accessToken

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

        Auth.syncWithFacebook(accessToken).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should return the user', ->
        expectedUserData = angular.extend
          email: responseData.email
          name: responseData.name
          imageUrl: responseData.image_url
        , Auth.user
        expect(response).toAngularEqual expectedUserData

      it 'should update the logged in user', ->
        expect(Auth.user).toBe response


    describe 'on error', ->

      it 'should reject the promise', ->
        status = 500
        $httpBackend.expectPOST fbSyncUrl, postData
          .respond status, null

        rejectedStatus = null
        Auth.syncWithFacebook(accessToken).then (->), (_status_) ->
          rejectedStatus = _status_
        $httpBackend.flush 1

        expect(rejectedStatus).toBe status


  describe 'sending a verification text', ->
    verifyPhoneUrl = null
    phone = null
    postData = null

    beforeEach ->
      verifyPhoneUrl = "#{apiRoot}/authcodes"
      phone = '+1234567890'
      postData = {phone: phone}

    describe 'on success', ->
      response = null

      beforeEach ->
        $httpBackend.expectPOST verifyPhoneUrl, postData
          .respond 200, null

        Auth.sendVerificationText(phone).then (->), (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should set Auth.phone', ->
        expect(Auth.phone).toBe phone

    describe 'on error', ->

      it 'should reject the promise', ->
        $httpBackend.expectPOST verifyPhoneUrl, postData
          .respond 500, null

        rejected = false
        Auth.sendVerificationText(phone).then (->), ->
          rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true


  describe 'checking whether a user is a friend', ->
    user = null

    beforeEach ->
      user =
        id: 1

    describe 'when the user is a friend', ->

      beforeEach ->
        Auth.friends[user.id] = true

      it 'should return true', ->
        expect(Auth.isFriend(user.id)).toBe true


    describe 'when the user isn\'t a friend', ->

      beforeEach ->
        Auth.friends = {}

      it 'should return true', ->
        expect(Auth.isFriend(user.id)).toBe false

  describe 'watching the users location', ->
    deferred = null
    updatedDeferred = null

    beforeEach ->
      deferred = $q.defer()
      $cordovaGeolocation.watchPosition.and.returnValue deferred.promise

      updatedDeferred = $q.defer()
      User.update.and.returnValue {$promise: updatedDeferred.promise}

      Auth.watchLocation()

    it 'should periodically ask the device for the users location', ->
      expect($cordovaGeolocation.watchPosition).toHaveBeenCalled()

    describe 'when location data is received sucessfully', ->
      user = null

      beforeEach ->
        lat = 180.0
        long = 180.0

        user = angular.copy Auth.user
        user.location = 
          lat: lat
          long: long
        
        position =
          coords:
            latitude: lat
            longitude: long

        deferred.notify position
        scope.$apply()

      it 'should save the user with the location data', ->
        expect(User.update).toHaveBeenCalledWith user

      describe 'when successful', ->

        beforeEach ->
          updatedDeferred.resolve user
          scope.$apply()

        it 'should update the Auth.user', ->
          expect(Auth.user).toBe user

    describe 'when location data cannot be recieved', ->

      describe 'because location permissions are denied', ->
        beforeEach ->
          error = 
            code: 'PositionError.PERMISSION_DENIED'

          deferred.reject error
          scope.$apply()

        it 'should send the user to the enable location services view', ->
          expect($state.go).toHaveBeenCalledWith 'requestLocation'


