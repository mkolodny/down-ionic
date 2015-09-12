require '../../ionic/ionic.js'
require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'angular-local-storage'
require 'ng-cordova'
require './auth-module'

describe 'Auth service', ->
  $cordovaGeolocation = null
  $cordovaDevice = null
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

  beforeEach angular.mock.module('ngCordova.plugins.device')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module(($provide) ->
    $cordovaGeolocation =
      watchPosition: jasmine.createSpy '$cordovaGeolocation.watchPosition'
    $provide.value '$cordovaGeolocation', $cordovaGeolocation

    deserializedUser =
      id: 1
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

  describe 'set user', ->
    user = null
    expectedUser = null

    beforeEach ->
      Auth.user =
        facebookFriends:
          2:
            id: 2
          3:
            id: 3
      user =
        id: 1
      expectedUser = angular.extend({}, Auth.user, user)

      Auth.setUser user

    it 'should extend passed in user with auth.user', ->
      expect(Auth.user).toEqual expectedUser

    it 'should save the user to localstorage', ->
      expect(localStorage.get 'currentUser').toEqual expectedUser


  describe 'set phone', ->
    phone = null

    beforeEach ->
      Auth.phone = null
      phone = '19252852230'
      Auth.setPhone phone

    it 'should set Auth.phone', ->
      expect(Auth.phone).toEqual phone

    it 'should save the phone to local storage', ->
      expect(localStorage.get 'currentPhone').toEqual phone


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
        Auth.isAuthenticated().then null, ->
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
        friend =
          id: 2
          email: 'jclarke@gmail.com'
          name: 'Joan Clarke'
          username: 'jmamba'
          image_url: 'http://imgur.com/jcke'
          location:
            type: 'Point'
            coordinates: [40.7265836, -73.9821539]
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
          friends: [friend]
          facebook_friends: [friend]
        $httpBackend.expectPOST authenticateUrl, postData
          .respond 200, responseData

        Auth.authenticate(phone, code).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should call deserialize with response data', ->
        expect(User.deserialize).toHaveBeenCalledWith responseData
        expect(User.deserialize.calls.count()).toBe 1

      it 'should get or create the user', ->
        expect(response).toAngularEqual deserializedUser

      it 'should set the returned user on the Auth object', ->
        expect(Auth.user).toEqual deserializedUser


    describe 'when the request fails', ->

      it 'should reject the promise', ->
        status = 500
        $httpBackend.expectPOST authenticateUrl, postData
          .respond status, null

        rejectedStatus = null
        Auth.authenticate(phone, code).then null, (_status_) ->
          rejectedStatus = _status_
        $httpBackend.flush 1

        expect(rejectedStatus).toEqual status


  describe 'logging in with facebook', ->
    fbAuthUrl = null
    accessToken = null
    postData = null

    beforeEach ->
      fbAuthUrl = "#{apiRoot}/sessions/facebook"
      accessToken = 'mikeisstinky'
      postData = access_token: accessToken

    describe 'on success', ->
      responseData = null
      response = null

      beforeEach ->
        friend =
          id: 2
          email: 'jclarke@gmail.com'
          name: 'Joan Clarke'
          username: 'jmamba'
          image_url: 'http://imgur.com/jcke'
          location:
            type: 'Point'
            coordinates: [40.7265836, -73.9821539]
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
          facebook_friends: [friend]
        $httpBackend.expectPOST fbAuthUrl, postData
          .respond 200, responseData

        Auth.facebookLogin(accessToken).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should call deserialize with response data', ->
        expect(User.deserialize).toHaveBeenCalledWith responseData
        expect(User.deserialize.calls.count()).toBe 1

      it 'should get or create the user', ->
        expect(response).toAngularEqual deserializedUser


    describe 'when the request fails', ->

      it 'should reject the promise', ->
        status = 500
        $httpBackend.expectPOST fbAuthUrl, postData
          .respond status, null

        rejectedStatus = null
        Auth.facebookLogin(accessToken).then null, (_status_) ->
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
      friend = null
      responseData = null
      response = null

      beforeEach ->
        spyOn Auth, 'setUser'

        Auth.user =
          id: 1
          location:
            lat: 40.7265834
            long: -73.9821535
          authtoken: 'fdsa4321'
        friend =
          id: 2
          email: 'jclarke@gmail.com'
          name: 'Joan Clarke'
          username: 'jnasty'
          image_url: 'https://facebook.com/profile-pics/jnasty'
        responseData =
          id: Auth.user.id
          email: 'aturing@gmail.com'
          name: 'Alan Turing'
          image_url: 'https://facebook.com/profile-pic/tdog'
          location:
            type: 'Point'
            coordinates: [Auth.user.location.lat, Auth.user.location.long]
          facebook_friends: [friend]
        $httpBackend.expectPOST fbSyncUrl, postData
          .respond 201, responseData

        facebookFriends = {}
        facebookFriends[friend.id] = friend
        deserializedUser =
          id: responseData.id
          email: responseData.email
          name: responseData.name
          imageUrl: responseData.image_url
          location:
            lat: responseData.location.coordinates[0]
            long: responseData.location.coordinates[1]
          facebookFriends: facebookFriends
        User.deserialize.and.returnValue deserializedUser

        Auth.facebookSync(accessToken).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should return the user', ->
        expect(response).toAngularEqual Auth.user

      it 'should save the user in local storage', ->
        expect(Auth.setUser).toHaveBeenCalledWith deserializedUser


    describe 'on error', ->

      it 'should reject the promise', ->
        status = 500
        $httpBackend.expectPOST fbSyncUrl, postData
          .respond status, null

        rejectedStatus = null
        Auth.facebookSync(accessToken).then null, (_status_) ->
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

        Auth.sendVerificationText(phone).then null, (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should set Auth.phone', ->
        expect(Auth.phone).toBe phone

    describe 'on error', ->

      it 'should reject the promise', ->
        $httpBackend.expectPOST verifyPhoneUrl, postData
          .respond 500, null

        rejected = false
        Auth.sendVerificationText(phone).then null, ->
          rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true


  describe 'checking whether a user is a friend', ->
    user = null

    beforeEach ->
      Auth.user.friends = {}
      user =
        id: 1

    describe 'when the user is a friend', ->

      beforeEach ->
        Auth.user.friends[user.id] = user

      it 'should return true', ->
        expect(Auth.isFriend user.id).toBe true


    describe 'when the user isn\'t a friend', ->

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


    describe 'the user doesn\'t have an image url', ->

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

    describe 'when using an iOS device', ->

      beforeEach ->
        spyOn(ionic.Platform, 'isIOS').and.returnValue true

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

      describe 'when using an iOS device', ->

        beforeEach ->
          spyOn(ionic.Platform, 'isIOS').and.returnValue true

        describe 'because location permissions are denied', ->
          beforeEach ->
            error =
              code: 1

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
          spyOn Auth, 'setUser'

          deferred.resolve user
          scope.$apply()

        it 'should update the Auth.user', ->
          expect(Auth.setUser).toHaveBeenCalledWith user


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

    describe 'when the user doesn\'t have a location', ->

      it 'should return false', ->
        expect(Auth.isNearby user).toBe false

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


  describe 'querying the user\'s facebook friends', ->
    url = null

    beforeEach ->
      url = "#{User.listUrl}/facebook-friends"

    describe 'successfully', ->
      response = null
      responseData = null

      beforeEach ->
        spyOn Auth, 'setUser'
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

        $httpBackend.expectGET url
          .respond 200, angular.toJson(responseData)

        response = null
        Auth.getFacebookFriends()
          .$promise.then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      it 'should GET the users', ->
        friend = User.deserialize responseData[0]
        facebookFriends = {}
        facebookFriends[friend.id] = friend
        expect(response).toAngularEqual facebookFriends

      it 'should save the friends on the user', ->
        user = angular.copy Auth.user
        friend = User.deserialize responseData[0]
        user.facebookFriends = {}
        user.facebookFriends[friend.id] = friend
        expect(Auth.setUser).toHaveBeenCalledWith user


    describe 'with a random error', ->
      rejected = null

      beforeEach ->
        $httpBackend.expectGET url
          .respond 500, ''

        rejected = false
        Auth.getFacebookFriends()
          .$promise.then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


    describe 'with a missing social account error', ->
      error = null

      beforeEach ->
        $httpBackend.expectGET url
          .respond 400, ''

        Auth.getFacebookFriends()
          .$promise.then null, (_error_) ->
            error = _error_
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(error).toBe 'MISSING_SOCIAL_ACCOUNT'
