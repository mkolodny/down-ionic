require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'angular-local-storage'
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
  Invitation = null
  User = null
  deserializedUser = null
  localStorage = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ngCordova.plugins.geolocation')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module(($provide) ->
    $cordovaGeolocation =
      watchPosition: jasmine.createSpy '$cordovaGeolocation.watchPosition'
    $provide.value '$cordovaGeolocation', $cordovaGeolocation

    deserializedUser = 'deserializedUser'
    User =
      update: jasmine.createSpy 'User.update'
      deserialize: jasmine.createSpy('User.deserialize').and.returnValue \
          deserializedUser
      listUrl: 'listUrl'
    $provide.value 'User', User

    $state =
      go: jasmine.createSpy '$state.go'
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
    Invitation = $injector.get 'Invitation'
    scope = $rootScope.$new()
    localStorage = $injector.get 'localStorageService'
  )

  afterEach ->
    localStorage.clearAll()

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
        Auth.isAuthenticated()
          .then (_result_) ->
            result = _result_
        $httpBackend.flush 1

        expect(result).toBe true


    describe 'when the user is not authenticated', ->

      it 'should return false', ->
        $httpBackend.expectGET testAuthUrl
          .respond 401, null

        result = null
        Auth.isAuthenticated()
          .then (_result_) ->
            result = _result_
        $httpBackend.flush 1

        expect(result).toBe false


    describe 'when the request fails', ->

      it 'should reject the promise', ->
        $httpBackend.expectGET testAuthUrl
          .respond 500, null

        rejected = false
        Auth.isAuthenticated()
          .then null, ->
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

        Auth.authenticate phone, code
          .then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      it 'should call deserialize with response data', ->
        expect(User.deserialize).toHaveBeenCalledWith responseData
        expect(User.deserialize.calls.count()).toBe 1

      it 'should get or create the user', ->
        expect(response).toAngularEqual deserializedUser

      it 'should set the returned user on the Auth object', ->
        expect(Auth.user).toBe deserializedUser

    describe 'when the request fails', ->

      it 'should reject the promise', ->
        status = 500
        $httpBackend.expectPOST authenticateUrl, postData
          .respond status, null

        rejectedStatus = null
        Auth.authenticate phone, code
          .then null, (_status_) ->
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

        Auth.syncWithFacebook accessToken
          .then (_response_) ->
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
        Auth.syncWithFacebook accessToken
          .then null, (_status_) ->
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

        Auth.sendVerificationText phone
          .then null, (_response_) ->
            response = _response_
        $httpBackend.flush 1

      it 'should set Auth.phone', ->
        expect(Auth.phone).toBe phone

    describe 'on error', ->

      it 'should reject the promise', ->
        $httpBackend.expectPOST verifyPhoneUrl, postData
          .respond 500, null

        rejected = false
        Auth.sendVerificationText phone
          .then null, ->
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
        expect(Auth.isFriend user.id).toBe true


    describe 'when the user isn\'t a friend', ->

      beforeEach ->
        Auth.friends = {}

      it 'should return true', ->
        expect(Auth.isFriend user.id).toBe false


  describe 'redirecting for auth state', ->

    describe 'no phone number entered', ->

      beforeEach ->
        Auth.phone = undefined
        Auth.redirectForAuthState()

      it 'should send the user to the enter phone view', ->
        expect($state.go).toHaveBeenCalledWith 'login'


    describe 'no authenticated user', ->

      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user = {}
        Auth.redirectForAuthState()

      it 'should send the user to the enter verification code view', ->
        expect($state.go).toHaveBeenCalledWith 'verifyPhone'


    describe 'the user doesn\'t have an email', ->

      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user =
          id: 1
        Auth.redirectForAuthState()

      it 'should send the user to the sync with facebook view', ->
        expect($state.go).toHaveBeenCalledWith 'facebookSync'


    describe 'the user doesn\'t have a username', ->

      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user =
          id: 1
          name: 'Alan Turing'
          email: 'aturing@gmail.com'
          imageUrl: 'https://facebook.com/profile-pic/tdog'
        Auth.redirectForAuthState()

      it 'should go to the add username view', ->
        expect($state.go).toHaveBeenCalledWith 'setUsername'


    describe 'we haven\'t requested location services', ->

      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user =
          id: 1
          name: 'Alan Turing'
          email: 'aturing@gmail.com'
          imageUrl: 'https://facebook.com/profile-pic/tdog'
          username: 'tdog'
        Auth.redirectForAuthState()

      it 'should go to the request push notifications view', ->
        expect($state.go).toHaveBeenCalledWith 'requestLocation'


    describe 'we haven\'t requested push services', ->

      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user =
          id: 1
          name: 'Alan Turing'
          email: 'aturing@gmail.com'
          imageUrl: 'https://facebook.com/profile-pic/tdog'
          location:
            lat: 40.7265834
            long: -73.9821535
          username: 'tdog'
        localStorage.set 'hasRequestedLocationServices', true
        Auth.redirectForAuthState()

      it 'should go to the request push notifications view', ->
        expect($state.go).toHaveBeenCalledWith 'requestPush'

    describe 'we haven\'t requested contacts access', ->

      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user =
          id: 1
          name: 'Alan Turing'
          email: 'aturing@gmail.com'
          imageUrl: 'https://facebook.com/profile-pic/tdog'
          location:
            lat: 40.7265834
            long: -73.9821535
          username: 'tdog'
        localStorage.set 'hasRequestedLocationServices', true
        localStorage.set 'hasRequestedPushNotifications', true
        Auth.redirectForAuthState()

      it 'should go to the request contacts view', ->
        expect($state.go).toHaveBeenCalledWith 'requestContacts'

    describe 'we haven\'t shown the find friends view', ->
      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user =
          id: 1
          name: 'Alan Turing'
          email: 'aturing@gmail.com'
          imageUrl: 'https://facebook.com/profile-pic/tdog'
          location:
            lat: 40.7265834
            long: -73.9821535
          username: 'tdog'
        localStorage.set 'hasRequestedLocationServices', true
        localStorage.set 'hasRequestedPushNotifications', true
        localStorage.set 'hasRequestedContacts', true
        Auth.redirectForAuthState()

      it 'should go to the find friends view', ->
        expect($state.go).toHaveBeenCalledWith 'findFriends'


    describe 'user has already completed sign up', ->

      beforeEach ->
        Auth.phone = '+19252852230'
        Auth.user =
          id: 1
          name: 'Alan Turing'
          email: 'aturing@gmail.com'
          imageUrl: 'https://facebook.com/profile-pic/tdog'
          location:
            lat: 40.7265834
            long: -73.9821535
          username: 'tdog'
        localStorage.set 'hasRequestedLocationServices', true
        localStorage.set 'hasRequestedPushNotifications', true
        localStorage.set 'hasRequestedContacts', true
        localStorage.set 'hasCompletedFindFriends', true
        Auth.redirectForAuthState()

      it 'should go to the events view', ->
        expect($state.go).toHaveBeenCalledWith 'events'


  describe 'watching the users location', ->
    cordovaDeferred = null
    promise = null

    beforeEach ->
      cordovaDeferred = $q.defer()
      $cordovaGeolocation.watchPosition.and.returnValue cordovaDeferred.promise

      spyOn Auth, 'updateLocation'

      promise = Auth.watchLocation()

    it 'should periodically ask the device for the users location', ->
      expect($cordovaGeolocation.watchPosition).toHaveBeenCalled()

    describe 'when location data is received sucessfully', ->
      user = null
      location = null
      resolved = null

      beforeEach ->
        lat = 180.0
        long = 180.0

        location =
          lat: lat
          long: long

        position =
          coords:
            latitude: lat
            longitude: long

        resolved = false
        promise.then ->
          resolved = true

        cordovaDeferred.notify position
        scope.$apply()

      it 'should call update location with the location data', ->
        expect(Auth.updateLocation).toHaveBeenCalledWith location

      it 'should resolve the promise', ->
        expect(resolved).toBe true


    describe 'when location data cannot be recieved', ->
      rejected = null

      describe 'because location permissions are denied', ->
        beforeEach ->
          error =
            code: 'PositionError.PERMISSION_DENIED'

          rejected = false
          promise.then null, ->
            rejected = true

          cordovaDeferred.reject error
          scope.$apply()

        it 'should send the user to the enable location services view', ->
          expect($state.go).toHaveBeenCalledWith 'requestLocation'

        it 'should reject the promise', ->
          expect(rejected).toBe true


      describe 'because of timeout or location unavailable', ->
        resolved = null

        beforeEach ->
          resolved = false
          promise.then ()->
            resolved = true

          error =
            code: 'PositionError.POSITION_UNAVAILABLE'

          cordovaDeferred.reject error
          scope.$apply()

        it 'should resolve the promise', ->
          expect(resolved).toBe true


  describe 'update the users location', ->
    deferred = null
    user = null

    beforeEach ->
      lat = 180.0
      long = 180.0

      location =
        lat: 180.0
        long: 180.0

      user = angular.copy Auth.user
      user.location = location

      deferred = $q.defer()
      User.update.and.returnValue {$promise: deferred.promise}

      Auth.updateLocation location

    it 'should save the user with the location data', ->
      expect(User.update).toHaveBeenCalledWith user

      describe 'when successful', ->

        beforeEach ->
          deferred.resolve user
          scope.$apply()

        it 'should update the Auth.user', ->
          expect(Auth.user).toBe user


  describe 'checking whether a friend is nearby', ->
    user = null

    beforeEach ->
      Auth.user.location =
        lat: 40.7265834
        long: -73.9821535
      user =
        id: 2
        email: 'jclarke@gmail.com'
        name: 'Joan Clarke'
        username: 'jnasty'
        imageUrl: 'https://facebook.com/profile-pics/jnasty'

    describe 'when the user is at most 5 mi away', ->

      beforeEach ->
        user.location =
          lat: 40.7265834 # just under 5 mi away
          long: -73.9821535

      it 'should return true', ->
        expect(Auth.isNearby user).toBe true


    describe 'when the user is more than 5 mi away', ->

      beforeEach ->
        user.location =
          lat: 40.79893 # just over 5 mi away
          long: -73.9821535

      it 'should return false', ->
        expect(Auth.isNearby user).toBe false
