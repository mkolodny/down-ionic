require 'angular-mocks'
require 'angular-local-storage'
require 'ng-cordova'
require './contacts-module'
require '../resources/resources-module'
require '../auth/auth-module'

describe 'Contacts service', ->
  $cordovaContacts = null
  scope = null
  $q = null
  localStorage = null
  Auth = null
  Contacts = null
  UserPhone = null

  beforeEach angular.mock.module('down.contacts')

  beforeEach angular.mock.module('ngCordova.plugins.contacts')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module(($provide) ->
    $cordovaContacts =
      find: jasmine.createSpy '$cordovaContacts.find'
    $provide.value '$cordovaContacts', $cordovaContacts

    Auth =
      phone: '+19252852230'
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    scope = $rootScope.$new()
    Auth = angular.copy $injector.get('Auth')
    localStorage = $injector.get 'localStorageService'
    UserPhone = $injector.get 'UserPhone'
    Contacts = angular.copy $injector.get('Contacts')
  )

  afterEach ->
    localStorage.clearAll()

  describe 'getting contacts', ->
    cordovaDeferred = null
    response = null
    error = null

    beforeEach ->
      cordovaDeferred = $q.defer()
      $cordovaContacts.find.and.returnValue cordovaDeferred.promise

      Contacts.getContacts().then (_response_) ->
        response = _response_
      , (_error_) ->
        error = _error_

    it 'should set hasRequestedContacts to true', ->
      expect(localStorage.get 'hasRequestedContacts').toEqual true

    it 'should get contacts name and phone numbers', ->
      fields = ['id', 'name', 'phoneNumbers']
      expect($cordovaContacts.find).toHaveBeenCalledWith fields

    describe 'when contacts are read successfully', ->
      contact = null
      contactId = null
      contacts = null
      phoneNumbers = null
      identifyDeferred = null

      beforeEach ->
        contactId = '1234'
        phoneNumbers = [
          value: '+19252852230'
        ]
        contact =
          id: contactId
          name: 'Mike Pleb'
          phoneNumbers: phoneNumbers
        contacts = [contact]

        spyOn(Contacts, 'filterContacts').and.returnValue contacts

        identifyDeferred = $q.defer()
        spyOn(Contacts, 'identifyContacts').and.returnValue \
            identifyDeferred.promise

        cordovaDeferred.resolve contacts
        scope.$apply()

      it 'should filter contacts', ->
        expect(Contacts.filterContacts).toHaveBeenCalledWith contacts

      it 'should identify contacts', ->
        expect(Contacts.identifyContacts).toHaveBeenCalledWith contacts

      describe 'and contacts are identified successfully', ->
        contactsObject = null

        beforeEach ->
          contactsObject = {"#{contactId}": contact}

          spyOn Contacts, 'saveContacts'

          identifyDeferred.resolve contactsObject
          scope.$apply()

        it 'should save the contacts', ->
          expect(Contacts.saveContacts).toHaveBeenCalledWith contactsObject

        it 'should resolve the promise with the contacts', ->
          expect(response).toEqual contactsObject


      describe 'identify error', ->

        beforeEach ->
          identifyDeferred.reject()
          scope.$apply()

        it 'should reject the promise', ->
          expect(error.code).toEqual 'IDENTIFY_FAILED'


    describe 'read contacts failed', ->

      beforeEach ->
        cordovaError =
          code: 'PERMISSION_DENIED_ERROR'

        cordovaDeferred.reject cordovaError
        scope.$apply()

      it 'should reject the promise', ->
        expect(error.code).toEqual 'PERMISSION_DENIED_ERROR'


  describe 'mapping contact id', ->
    contactIdMap = null
    phone1 = null
    phone2 = null
    contactId = null

    beforeEach ->
      contactId = '12345'
      phone1 = '+19252852230'
      phone2 = '+12345678910'
      contact =
        id: contactId
        phoneNumbers: [
          value: phone1
        ,
          value: phone2
        ]

      contactIdMap = Contacts.mapContactIds [contact]

    it 'should return an object with phones as keys and contact id as value', ->
      expectResult = {}
      expectResult[phone1] = contactId
      expectResult[phone2] = contactId
      expect(contactIdMap).toEqual expectResult


  describe 'identifying contacts', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Contacts, 'getContactUsers').and.returnValue deferred.promise

    describe 'successfully', ->
      contactId = null
      phone = null
      contact = null
      user = null
      identifiedContacts = null

      beforeEach ->
        contactId = '1234'
        phone = '+19252855230'

        contact =
          id: contactId
          phoneNumbers: [
            value: phone
          ]

        contactCopy = angular.copy contact
        Contacts.identifyContacts([contactCopy]).then (_contacts_) ->
          identifiedContacts = _contacts_

        user =
          id: 98765
        userPhone =
          user: user
          phone: phone
        deferred.resolve [userPhone]
        scope.$apply()

      it 'should add a user property to contacts that have users', ->
        expect(identifiedContacts[contactId].user).toBe user


    describe 'not successfully :(', ->
      rejected = null

      beforeEach ->
        rejected = false
        Contacts.identifyContacts []
          .then null, ->
            rejected = true

        deferred.reject()
        scope.$apply()

      it 'should reject the promise', ->
        expect(rejected).toEqual true


  describe 'converting a contacts array to an object', ->
    contactId = null
    contact = null
    contactsObject = null

    beforeEach ->
      contactId = '12345'
      contact =
        id: contactId
        name: 'Mike Pleb'
      contactsObject = Contacts.contactArrayToObject [contact]

    it 'should return an object with key contact id and value contact', ->
      expect(contactsObject).toEqual {"#{contactId}": contact}


  describe 'getting contact users', ->
    phone1 = null
    phone2 = null
    phone3 = null

    deferred = null
    promise = null

    beforeEach ->
      phone1 = '+19252852230'
      contact1 =
        id: '1234'
        phoneNumbers: [
          value: phone1
        ]

      phone2 = '+12345678910'
      phone3 = '+15555555555'
      contact2 =
        id: '1122'
        phoneNumbers: [
          value: phone2
        ,
          value: phone3
        ]

      deferred = $q.defer()
      spyOn(UserPhone, 'getFromPhones').and.returnValue {$promise: deferred.promise}

      contacts = [contact1, contact2]
      contactsCopy = angular.copy contacts

      promise = Contacts.getContactUsers contactsCopy

    it 'should check contacts to see if a users exist for every number', ->
      allPhones = [phone1, phone2, phone3]
      expect(UserPhone.getFromPhones).toHaveBeenCalledWith allPhones

    it 'should return a promise', ->
      expect(promise).toBe deferred.promise


  describe 'filtering contacts', ->
    contacts = null
    formattedContacts = null
    contact1 = null

    describe 'when a contact doesn\'t have a name', ->
      filteredContacts = null

      beforeEach ->
        contact =
          name:
            formatted: '' # NOTE: formatted may not be an empty string,
                          #   test on devices.
        filteredContacts = Contacts.filterContacts [contact]

      it 'should remove contacts with no names', ->
        expect(filteredContacts).toEqual []


    describe 'when a contact does have a name', ->
      filteredContacts = null

      beforeEach ->
        contact =
          name:
            formatted: 'Jimbo Walker'
        contacts = [contact]
        contactsCopy = angular.copy contacts
        filteredContacts = Contacts.filterContacts contactsCopy

      it 'should return contacts with names', ->
        expect(filteredContacts).toEqual contacts


  describe 'saving contacts', ->
    contact = null

    beforeEach ->
      contact =
        id: '1234'
        name:
          formatted: 'Mike Pleb'

      localStorage.set 'contacts', {}
      Contacts.saveContacts [contact]

    it 'should save the contact to localStorage', ->
      savedContacts = localStorage.get 'contacts'
      expect(savedContacts).toEqual [contact]
