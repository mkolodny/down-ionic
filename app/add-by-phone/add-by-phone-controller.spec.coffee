require 'angular'
require 'angular-mocks'
require '../common/auth/auth-module'
AddByPhoneCtrl = require './add-by-phone-controller'

describe 'add by phone controller', ->
  $q = null
  $timeout = null
  Auth = null
  ctrl = null
  scope = null
  UserPhone = null

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $timeout = $injector.get '$timeout'
    Auth = $injector.get 'Auth'
    scope = $rootScope.$new true
    UserPhone = $injector.get 'UserPhone'

    ctrl = $controller AddByPhoneCtrl,
      $scope: scope
      Auth: Auth
      UserPhone: UserPhone
  )

  it 'should set the current user on the controller', ->
    expect(ctrl.currentUser).toBe Auth.user

  describe 'searching for a user by phone', ->
    phone = null
    deferred = null

    beforeEach ->
      phone = '+19252852230'
      ctrl.phone = phone
      phoneForm = 
        $valid: true
        phone:
          $validate: ->

      deferred = $q.defer()
      spyOn(UserPhone, 'save').and.returnValue {$promise: deferred.promise}
      
      ctrl.search(phoneForm)

    it 'should set a searching flag', ->
      expect(ctrl.isSearching).toBe true

    it 'should clear the friend', ->
      expect(ctrl.friend).toBe null

    it 'should save the userPhone', ->
      expect(UserPhone.save).toHaveBeenCalledWith {phone: phone}

    describe 'request returns successfully', ->
      userPhone = null
      user = null

      beforeEach ->
        user =
          id: 1
          email: 'aturing@gmail.com'
          name: 'Alan Turing'
          phone: 'tdog'
          imageUrl: 'https://facebook.com/profile-pics/tdog'
          location:
            lat: 40.7265834
            long: -73.9821535
        userPhone =
          phone: ctrl.phone
          user: user
            
        deferred.resolve userPhone
        scope.$apply()

      describe 'when the phone hasn\'t changed', ->

        it 'should set the friend on the controller', ->
          expect(ctrl.friend).toBe user

        it 'should set searching to false', ->
          expect(ctrl.isSearching).toBe false


    describe 'when the request is unsuccessful', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.searchError).toBe true

      it 'should set searching to false', ->
        expect(ctrl.isSearching).toBe false
