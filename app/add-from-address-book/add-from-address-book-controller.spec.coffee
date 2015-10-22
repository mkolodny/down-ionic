require 'angular'
require 'angular-mocks'
require '../common/contacts/contacts-module'
require '../common/resources/resources-module'
require '../common/local-db/local-db-module'
AddFromAddressBookCtrl = require './add-from-address-book-controller'

describe 'add from address book controller', ->
  $controller = null
  $q = null
  Contacts = null
  contactsObject = null
  ctrl = null
  LocalDB = null
  localDBDeferred = null
  scope = null
  user = null
  User = null

  beforeEach angular.mock.module('rallytap.localDB')

  beforeEach angular.mock.module('rallytap.contacts')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    scope = $injector.get '$rootScope'
    Contacts = $injector.get 'Contacts'
    LocalDB = $injector.get 'LocalDB'
    User = $injector.get 'User'

    # Mock contacts being saved in local storage.
    user = # One of the contacts is a Rallytap user.
      id: 3
      email: 'aturing@gmail.com'
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535
    contactsObject =
      1:
        id: 1
        name: ' Bruce Lee' # Test a space in there
        username: null
      2: user

    localDBDeferred = $q.defer()
    spyOn(LocalDB, 'get').and.returnValue localDBDeferred.promise

    ctrl = $controller AddFromAddressBookCtrl,
      $scope: scope
  )

  it 'should get the contacts', ->
    expect(LocalDB.get).toHaveBeenCalledWith 'contacts'

  describe 'when successful', ->

    describe 'when contacts are in the localDB', ->

      beforeEach ->
        spyOn ctrl, 'showContacts'

        localDBDeferred.resolve contactsObject
        scope.$apply()

      it 'should show the contacts', ->
        expect(ctrl.showContacts).toHaveBeenCalled()


    describe 'when the user\'s contacts haven\'t been saved yet', ->

      beforeEach ->
        spyOn ctrl, 'refresh'

        localDBDeferred.resolve null
        scope.$apply()

      it 'should show the loading spinner', ->
        expect(ctrl.isLoading).toBe true

      it 'should request the user\'s contacts', ->
        expect(ctrl.refresh).toHaveBeenCalled()


    describe 'on LocalDB error', ->

      beforeEach ->
        localDBDeferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.getContactsError).toBe true


  describe 'show contacts', ->

    beforeEach ->
      ctrl.showContacts contactsObject

    it 'should set the contacts items on the controller', ->
      contact = contactsObject[1]
      contact.name = contact.name.trim()
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
        user: new User contact
      ]
      expect(ctrl.items).toEqual items


  describe 'getting contacts', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Contacts, 'getContacts').and.returnValue deferred.promise

      ctrl.refresh()

    describe 'when the load succeeds', ->

      beforeEach ->
        spyOn ctrl, 'showContacts'

        deferred.resolve contactsObject
        scope.$apply()

      it 'should show the friends', ->
        expect(ctrl.showContacts).toHaveBeenCalledWith contactsObject

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
        newContacts = angular.copy contactsObject
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
        expect(ctrl.getInitials 'Alan Danger Turing').toBe 'AT'


    describe 'when they have one word in their name', ->

      it 'should return the first two letters of their name', ->
        expect(ctrl.getInitials 'Pele').toBe 'PE'


    describe 'when they have one letter in their name', ->

      it 'should return the first letter of their name', ->
        expect(ctrl.getInitials 'p').toBe 'P'
