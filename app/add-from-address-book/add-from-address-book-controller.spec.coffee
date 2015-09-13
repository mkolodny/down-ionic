require 'angular'
require 'angular-local-storage'
require 'angular-mocks'
require '../common/contacts/contacts-module'
require '../common/resources/resources-module'
AddFromAddressBookCtrl = require './add-from-address-book-controller'

describe 'add from address book controller', ->
  $controller = null
  $q = null
  Contacts = null
  contacts = null
  ctrl = null
  localStorage = null
  scope = null
  user = null
  User = null

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module('down.contacts')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    scope = $injector.get '$rootScope'
    Contacts = $injector.get 'Contacts'
    localStorage = $injector.get 'localStorageService'
    User = $injector.get 'User'

    # Mock contacts being saved in local storage.
    user = # One of the contacts is a Down user.
      id: 3
      email: 'aturing@gmail.com'
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535
    contacts =
      1:
        id: 1
        name: 'Bruce Lee'
        username: null
      2: user
    localStorage.set 'contacts', contacts

    ctrl = $controller AddFromAddressBookCtrl,
      $scope: scope
  )

  afterEach ->
    localStorage.clearAll()

  it 'should set the contacts on the controller', ->
    items = [
      isDivider: true
      title: 'A'
    ,
      isDivider: false
      user: new User user
    ,
      isDivider: true
      title: 'B'
    ,
      isDivider: false
      contact: contacts[1]
    ]
    expect(ctrl.items).toEqual items

  describe 'when the user\'s contacts haven\'t been saved yet', ->
    deferred = null

    beforeEach ->
      localStorage.clearAll()

      deferred = $q.defer()
      spyOn(Contacts, 'getContacts').and.returnValue deferred.promise

      ctrl = $controller AddFromAddressBookCtrl,
        $scope: scope

    it 'should show the loading spinner', ->
      expect(ctrl.isLoading).toBe true

    it 'should request the user\'s contacts', ->
      expect(Contacts.getContacts).toHaveBeenCalled()

    describe 'when the load succeeds', ->

      beforeEach ->
        spyOn ctrl, 'showContacts'

        deferred.resolve contacts
        scope.$apply()

      it 'should show the friends', ->
        expect(ctrl.showContacts).toHaveBeenCalledWith contacts

      it 'should hide the loading spinner', ->
        expect(ctrl.isLoading).toBe false


    describe 'when the load fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.getContactsError).toBe true

      it 'should hide the loading spinner', ->
        expect(ctrl.isLoading).toBe false


  describe 'pulling to refresh', ->
    deferred = null
    refreshComplete = null

    beforeEach ->
      # Listen to the refresh complete event to check whether we've broadcasted
      # the event.
      refreshComplete = false
      scope.$on 'scroll.refreshComplete', ->
        refreshComplete = true

      deferred = $q.defer()
      spyOn(Contacts, 'getContacts').and.returnValue deferred.promise
      spyOn ctrl, 'showContacts'

      ctrl.refresh()

    it 'should fetch the user\'s contacts', ->
      expect(Contacts.getContacts).toHaveBeenCalled()

    describe 'when the request succeeds', ->
      newContacts = null

      beforeEach ->
        newContacts = angular.copy contacts
        newContacts[3] =
          name:
            formatted: 'Marie Curie'
          phoneNumbers: [
            type: 'home'
            value: '4345678901'
            pref: true
          ]
        deferred.resolve newContacts
        scope.$apply()

      it 'should show the contacts', ->
        expect(ctrl.showContacts).toHaveBeenCalledWith newContacts

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true

      it 'should clear a load error', ->
        expect(ctrl.getContactsError).toBe false


    describe 'when the request fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true

      it 'should show a load error', ->
        expect(ctrl.getContactsError).toBe true


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


    describe 'when they have no last name', ->

      describe 'and multiple letters in their first name', ->

        it 'should return the first two letters of their first name', ->
          expect(ctrl.getInitials 'Pele ').toBe 'PE'


      describe 'and one letter in their first name', ->

        it 'should return the first two letters of their first name', ->
          expect(ctrl.getInitials 'P ').toBe 'P'
