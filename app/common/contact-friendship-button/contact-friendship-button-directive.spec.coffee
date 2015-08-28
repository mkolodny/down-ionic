require 'angular'
require 'angular-mocks'
require '../../vendor/intl-phone/libphonenumber-utils.js'
require '../resources/resources-module'
require './contact-friendship-button-module'

describe 'contact friendship button directive', ->
  $compile = null
  $q = null
  Auth = null
  element = null
  scope = null
  UserPhone = null

  beforeEach angular.mock.module('down.contactFriendshipButton')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module(($provide) ->
    Auth =
      user:
        id: 1
        friends: []
      setUser: jasmine.createSpy 'Auth.setUser'
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    scope = $rootScope.$new()
    UserPhone = $injector.get 'UserPhone'

    # Mock setting the contact in the current scope.
    scope.contact =
      id: 1
      name: 'Alan Turing'
      phoneNumbers: [
        type: 'mobile'
        value: '2036227310'
        pref: true
      ]

    element = angular.element """
      <contact-friendship-button contact="contact">
      """
    $compile(element) scope
    scope.$digest()
  )

  describe 'tapping the add friend button', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(UserPhone, 'create').and.returnValue deferred.promise

      anchor = element.find 'a'
      anchor.triggerHandler 'click'

    it 'should show a spinner', ->
      icon = element.find 'ion-spinner'
      expect(icon.length).toBe 1

    it 'should create the userphone', ->
      expect(UserPhone.create).toHaveBeenCalledWith scope.contact

    describe 'when the add succeeds', ->
      user = null
      contact = null

      beforeEach ->
        user =
          id: 1
        contact = angular.extend {}, scope.contact,
          user: user
        data =
          contact: contact
          userphone:
            user: user
            phone: '+12036227310'
        deferred.resolve data
        scope.$apply()

      it 'should get the contact from local storage', ->
        expect(scope.contact).toEqual contact

      it 'should add the new friend to the user\'s friends object', ->
        expect(Auth.user.friends).toEqual [user]

      it 'should set the updated user', ->
        expect(Auth.setUser).toHaveBeenCalledWith Auth.user


    describe 'when the add fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should the show add friend button', ->
        icon = element.find 'i'
        expect(icon).toHaveClass 'fa-plus-square-o'
