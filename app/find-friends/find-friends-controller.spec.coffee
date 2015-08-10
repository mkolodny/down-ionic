require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'angular-local-storage'
require '../common/auth/auth-module'
require '../common/contacts/contacts-module'
FindFriendsCtrl = require './find-friends-controller'

describe 'find friends controller', ->
  $q = null
  $state = null
  Auth = null
  ctrl = null
  deferred = null
  contactsDeferred = null
  scope = null
  Contacts = null
  User = null
  localStorage = null
  facebookFriend = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.contacts')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    Contacts = $injector.get 'Contacts'
    scope = $rootScope.$new true
    User = $injector.get 'User'
    localStorage = $injector.get 'localStorageService'

    deferred = $q.defer()
    spyOn(User, 'getFacebookFriends').and.returnValue {$promise: deferred.promise}

    contactsDeferred = $q.defer()
    spyOn(Contacts, 'getContacts').and.returnValue contactsDeferred.promise

    # Need dis in the constructor
    facebookFriend =
      id: '1234'
      name: 'Chris Pleb'
      username: 'm'
      imageUrl: 'thatImage.com'
    Auth.user.facebookFriends = [facebookFriend]

    ctrl = $controller FindFriendsCtrl,
      Auth: Auth
      $scope: scope
      Contacts: Contacts
  )

  xit 'should request the user\'s contacts', ->
    expect(Contacts.getContacts).toHaveBeenCalled()

  xit 'should set isLoading to true', ->
    expect(ctrl.isLoading).toEqual true

  xdescribe 'when the user has facebook friends', ->

    it 'should create and set items for facebook friends', ->
      items = [
        isDivider: true
        title: 'Friends Using Down'
      ,
        isDivider: false
        user:
          id: facebookFriend.id
          name: facebookFriend.name
          username: facebookFriend.username
          imageUrl: facebookFriend.imageUrl
      ,
        isDivider: true
        title: 'Contacts'
      ]

      expect(ctrl.items).toEqual items


  xdescribe 'when get contacts returns', ->

    describe 'successfully', ->
      contacts = null
      items = null

      beforeEach ->
        contact =
          id: 1234
          name: 'Mike Pleb'
          phoneNumbers: [
            value: '+1952852230'
          ]
        items = [
          isDivider: true
          title: 'Friends Using Down'
        ,
          isDivider: false
          user: facebookFriend
        ,
          isDivider: true
          title: 'Contacts'
        ,
          isDivider: false
          contact: contact
        ]
        spyOn(ctrl, 'buildItems').and.returnValue items

        contacts =
          1234: contact
        contactsDeferred.resolve contacts
        scope.$apply()

      it 'should set isLoading to false', ->
        expect(ctrl.isLoading).toEqual false

      it 'should build the items list', ->
        expect(ctrl.buildItems).toHaveBeenCalledWith Auth.user.facebookFriends,
            contacts

      it 'should set the items on the controller', ->
        expect(ctrl.items).toBe items


    describe 'with an error', ->
      beforeEach ->
        contactsDeferred.reject()
        scope.$apply()

      it 'should set isLoading to false', ->
        expect(ctrl.isLoading).toEqual false

      it 'should show an error', ->
        expect(ctrl.contactsRequestError).toBe true


  describe 'building the items list', ->
    contactNoUser = null
    contactUser = null
    result = null

    beforeEach ->
      contactNoUser =
        id: 1
        name: 'Mike Pleb'
        phoneNumbers: [
          value: '+1952852230'
        ]
      contactUser =
        id: 2
        name: 'Andrew Plebfoot'
        phoneNumbers: [
          value: '+1952852231'
        ]
        user:
          id: 3
          name: 'Andrew Plebfoot'
          username: 'a'
      contacts =
        "#{contactNoUser.id}": contactNoUser
        "#{contactUser.id}": contactUser

      result = ctrl.buildItems Auth.user.facebookFriends, contacts

    it 'should return the built items', ->
      items = [
        isDivider: true
        title: 'Friends Using Down'
      ,
        isDivider: false
        user: contactUser.user
      ,
        isDivider: false
        user: facebookFriend
      ,
        isDivider: true
        title: 'Contacts'
      ,
        isDivider: false
        contact: contactNoUser
      ]
      expect(result).toEqual items


  describe 'when the user finishes', ->

    beforeEach ->
      spyOn Auth, 'redirectForAuthState'
      localStorage.set 'hasCompletedFindFriends', false

      ctrl.done()

    afterEach ->
      localStorage.clearAll()

    it 'should set localStorage.hasCompletedFindFriends', ->
      expect(localStorage.get 'hasCompletedFindFriends').toBe true

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()


  describe 'getting a contact\'s initials', ->

    describe 'when they have multiple words in their name', ->

      it 'should return the first letter of their first and last name', ->
        expect(ctrl.getInitials 'Alan Tdog Turing').toBe 'AT'


    describe 'when they have one word in their name', ->

      it 'should return the first two letters of their name', ->
        expect(ctrl.getInitials 'Pele').toBe 'PE'


    describe 'when they have one letter in their name', ->

      it 'should return the first letter of their name', ->
        expect(ctrl.getInitials 'p').toBe 'P'
