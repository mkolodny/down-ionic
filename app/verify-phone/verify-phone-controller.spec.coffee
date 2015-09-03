require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
Asteroid = require '../common/asteroid/asteroid-module'
VerifyPhoneCtrl = require './verify-phone-controller'

describe 'verify phone controller', ->
  $ionicLoading = null
  $q = null
  $rootScope = null
  $state = null
  ctrl = null
  Auth = null
  Asteroid = null
  scope = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.asteroid')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicLoading = $injector.get '$ionicLoading'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    Asteroid = $injector.get 'Asteroid'
    scope = $rootScope.$new()

    Auth.phone = '+15555555555'

    ctrl = $controller VerifyPhoneCtrl,
      Auth: Auth
      $scope: scope
  )

  describe 'when form is submitted', ->
    deferred = null

    beforeEach ->
      spyOn ctrl, 'validate'
      ctrl.code = '1234'
      deferred = $q.defer()
      spyOn(Auth, 'authenticate').and.returnValue deferred.promise

      ctrl.authenticate()

    it 'should validate the form', ->
      expect(ctrl.validate).toHaveBeenCalled()

    describe 'when the form validates', ->

      beforeEach ->
        spyOn $ionicLoading, 'show'
        spyOn $ionicLoading, 'hide'
        ctrl.validate.and.returnValue true

        ctrl.authenticate()

      it 'should call Auth.authenticate with phone and code', ->
        expect(Auth.authenticate).toHaveBeenCalledWith Auth.phone, ctrl.code

      describe 'when authentication is successful', ->
        user = null

        beforeEach ->
          spyOn ctrl, 'meteorLogin'
          spyOn Auth, 'setPhone'

          user = {}
          deferred.resolve user
          scope.$apply()

        it 'should set the phone to store in localStorage', ->
          expect(Auth.setPhone).toHaveBeenCalledWith Auth.phone

        it 'should login to the meteor server', ->
          expect(ctrl.meteorLogin).toHaveBeenCalledWith user

        it 'should show the loading overlay', ->
          template = '''
            <div class="loading-text">Logging you in...</div>
            <ion-spinner icon="bubbles"></ion-spinner>
            '''
          expect($ionicLoading.show).toHaveBeenCalledWith {template: template}


      describe 'when authentication fails', ->

        describe 'because the code was incorrect', ->

          beforeEach ->
            deferred.reject 401
            $rootScope.$apply()

          it 'should show an error', ->
            expect(ctrl.error).toBe 'Oops, something went wrong.'

          it 'should hide the loading overlay', ->
            expect($ionicLoading.hide).toHaveBeenCalled()


        describe 'because the code was incorrect', ->

          beforeEach ->
            deferred.reject 500
            $rootScope.$apply()

          it 'should show an error', ->
            expect(ctrl.error).toBe 'Looks like you entered the wrong code :('


  describe 'validating the verify phone form', ->

    describe 'when the form is valid', ->
      result = null

      beforeEach ->
        scope.verifyPhoneForm = $valid: true

        result = ctrl.validate()

      it 'should return true', ->
        expect(result).toBe true


    describe 'when the form is invalid', ->
      result = null

      beforeEach ->
        scope.verifyPhoneForm = $valid: false

        result = ctrl.validate()

      it 'should return false', ->
        expect(result).toBe false


  describe 'logging into the meteor server', ->
    deferred = null
    user = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Asteroid, 'login').and.returnValue deferred.promise

      user =
        id: 1
        email: 'aturing@gmail.com'
      ctrl.meteorLogin user

    it 'should attempt to login', ->
      expect(Asteroid.login).toHaveBeenCalled()

    describe 'successfully', ->

      beforeEach ->
        spyOn ctrl, 'getFacebookFriends'
        spyOn Auth, 'setUser'

      describe 'when the user doesn\'t have a social account yet', ->

        beforeEach ->
          user.email = undefined
          spyOn $state, 'go'

          deferred.resolve()
          scope.$apply()

        it 'should save the user', ->
          expect(Auth.setUser).toHaveBeenCalledWith user

        it 'should go to the sync with facebook view', ->
          expect($state.go).toHaveBeenCalledWith 'facebookSync'


      describe 'when the user has a social account', ->

        beforeEach ->
          deferred.resolve()
          scope.$apply()

        it 'should save the user', ->
          expect(Auth.setUser).toHaveBeenCalledWith user

        it 'should get the user\'s facebook friends', ->
          expect(ctrl.getFacebookFriends).toHaveBeenCalled()


    describe 'unsuccessfully', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.error).toBe 'Oops, something went wrong.'

  describe 'get facebook friends', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Auth, 'getFacebookFriends').and.returnValue {$promise: deferred.promise}

      ctrl.getFacebookFriends()

    it 'should call User.getFacebookFriends', ->
      expect(Auth.getFacebookFriends).toHaveBeenCalled()

    describe 'successfully', ->
      friends = null

      beforeEach ->
        spyOn(Auth, 'redirectForAuthState')
        spyOn(Auth, 'setUser')

        friends =
          1:
            id: 1
          2:
            id: 2
        deferred.resolve friends
        scope.$apply()

      it 'should set the friends on auth', ->
        expect(Auth.user.facebookFriends).toEqual friends

      it 'should call Auth.setUser', ->
        expect(Auth.setUser).toHaveBeenCalledWith Auth.user

      it 'should redirectForAuthState', ->
        expect(Auth.redirectForAuthState).toHaveBeenCalled()

    describe 'error', ->

      describe 'facebook access token expired', ->

        beforeEach ->
          spyOn $state, 'go'

          deferred.reject 'MISSING_SOCIAL_ACCOUNT'
          scope.$apply()

        it 'should send user to sync with facebook', ->
          expect($state.go).toHaveBeenCalledWith 'facebookSync'


      describe 'other error', ->
        beforeEach ->

          deferred.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'Oops, something went wrong.'
