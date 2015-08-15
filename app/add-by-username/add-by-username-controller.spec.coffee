require 'angular'
require 'angular-mocks'
require '../common/auth/auth-module'
AddByUsernameCtrl = require './add-by-username-controller'

describe 'add by username controller', ->
  $q = null
  $timeout = null
  Auth = null
  ctrl = null
  scope = null
  User = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $timeout = $injector.get '$timeout'
    Auth = angular.copy $injector.get('Auth')
    scope = $rootScope.$new true
    User = $injector.get 'User'

    ctrl = $controller AddByUsernameCtrl,
      $scope: scope
      Auth: Auth
  )

  it 'should set the user on the controller', ->
    expect(ctrl.user).toBe Auth.user

  describe 'searching for a user by username', ->
    deferred = null
    timer = null

    beforeEach ->
      ctrl.username = 'tdog'
      timer = {}
      ctrl.timer = angular.copy timer

      spyOn($timeout, 'cancel')

      deferred = $q.defer()
      spyOn(User, 'query').and.returnValue {$promise: deferred.promise}

      ctrl.search()

    it 'should set a searching flag', ->
      expect(ctrl.isSearching).toBe true

    it 'should clear the friend', ->
      expect(ctrl.friend).toBe null

    it 'should cancel existing timeout', ->
      expect($timeout.cancel).toHaveBeenCalledWith timer

    describe 'after 300ms', ->

      beforeEach ->
        $timeout.flush 300

      it 'should try to get the user', ->
        expect(User.query).toHaveBeenCalledWith {username: ctrl.username}

      describe 'when the username hasn\'t changed', ->

        describe 'when a user is returned', ->
          friend = null

          beforeEach ->
            friend =
              id: 1
              email: 'aturing@gmail.com'
              name: 'Alan Turing'
              username: 'tdog'
              imageUrl: 'https://facebook.com/profile-pics/tdog'
              location:
                lat: 40.7265834
                long: -73.9821535
            deferred.resolve [friend]
            scope.$apply()

          it 'should set the friend on the controller', ->
            expect(ctrl.friend).toBe friend

          it 'should set searching to false', ->
            expect(ctrl.isSearching).toBe false

        describe 'when no users are returned', ->

          beforeEach ->
            deferred.resolve []
            scope.$apply()

          it 'should set searching to false', ->
            expect(ctrl.isSearching).toBe false

        describe 'when the search is unsuccessful', ->

          beforeEach ->
            deferred.reject()
            scope.$apply()

          it 'should show an error', ->
            expect(ctrl.searchError).toBe true

          it 'should set searching to false', ->
            expect(ctrl.isSearching).toBe false
