require 'angular'
require 'angular-mocks'
require 'angular-local-storage'
require 'angular-ui-router'
VerifyPhoneCtrl = require './verify-phone-controller'

describe 'verify phone controller', ->
  $q = null
  $rootScope = null
  $state = null
  ctrl = null
  Auth = null
  localStorage = null
  User = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    localStorage = $injector.get 'localStorageService'
    User = $injector.get 'User'

    Auth.phone = '+15555555555'

    ctrl = $controller VerifyPhoneCtrl,
      Auth: Auth
  )

  afterEach ->
    localStorage.clearAll()

  describe 'when form is submitted', ->
    deferred = null
    promise = null

    beforeEach ->
      ctrl.code = '1234'
      deferred = $q.defer()
      promise = deferred.promise
      spyOn(Auth, 'authenticate').and.returnValue promise
      ctrl.authenticate()

    it 'should call Auth.authenticate with phone and code', ->
      expect(Auth.authenticate).toHaveBeenCalledWith Auth.phone, ctrl.code

    describe 'when authentication is successful', ->
      user = null

      beforeEach ->
        spyOn $state, 'go'

      describe 'when the user doesn\'t have an email', ->

        beforeEach ->
          user =
            id: 1
          deferred.resolve user
          $rootScope.$apply()

        it 'should go to the sync with facebook view', ->
          expect($state.go).toHaveBeenCalledWith 'facebookSync'


      describe 'the user doesn\'t have a username', ->

        beforeEach ->
          user =
            id: 1
            name: 'Alan Turing'
            email: 'aturing@gmail.com'
            imageUrl: 'https://facebook.com/profile-pic/tdog'
          deferred.resolve user
          $rootScope.$apply()

        it 'should go to the add username view', ->
          expect($state.go).toHaveBeenCalledWith 'setUsername'


      describe 'the user hasn\'t allowed push notifications yet', ->

        beforeEach ->
          user =
            id: 1
            name: 'Alan Turing'
            email: 'aturing@gmail.com'
            imageUrl: 'https://facebook.com/profile-pic/tdog'
            location:
              lat: 40.7265834
              long: -73.9821535
            username: 'tdog'
          deferred.resolve user
          $rootScope.$apply()

        it 'should go to the request push notifications view', ->
          expect($state.go).toHaveBeenCalledWith 'requestPushServices'


      describe 'the user has already signed up', ->

        beforeEach ->
          user =
            id: 1
            name: 'Alan Turing'
            email: 'aturing@gmail.com'
            imageUrl: 'https://facebook.com/profile-pic/tdog'
            location:
              lat: 40.7265834
              long: -73.9821535
            username: 'tdog'
          localStorage.set 'hasAllowedPushNotifications', true
          deferred.resolve user
          $rootScope.$apply()

        it 'should go to the events view', ->
          expect($state.go).toHaveBeenCalledWith 'events'


    describe 'when authentication fails', ->

      describe 'because the code was incorrect', ->

        beforeEach ->
          deferred.reject 401
          $rootScope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'Oops, something went wrong.'


      describe 'because the code was incorrect', ->

        beforeEach ->
          deferred.reject 500
          $rootScope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'Looks like you entered the wrong code :('
