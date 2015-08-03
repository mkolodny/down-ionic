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
      find: jasmine.createSpy('$cordovaContacts.find')
    $provide.value '$cordovaContacts', $cordovaContacts

    return
  )

  beforeEach inject(($injector) ->
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    scope = $rootScope.$new()
    Auth = $injector.get 'Auth'
    localStorage = $injector.get 'localStorageService'
    UserPhone = $injector.get 'UserPhone'
    Contacts = angular.copy $injector.get('Contacts')
  )

  afterEach ->
    localStorage.clearAll()

  describe 'get contacts', ->
    fields = null
    cordovaDeferred = null
    resolved = null
    error = null

    beforeEach ->
      fields = ['id', 'name', 'phoneNumbers']
      localStorage.set('hasRequestedContacts', false)

      cordovaDeferred = $q.defer()
      $cordovaContacts.find.and.returnValue cordovaDeferred.promise

      resolved = false
      error = null
      Contacts.getContacts()
        .then () ->
          resolved = true
        , (_error_) ->
          error = _error_

    it 'should set hasRequestedContacts to true', ->
      expect(localStorage.get('hasRequestedContacts')).toEqual true

    it 'should get contacts name and phone numbers', ->
      expect($cordovaContacts.find).toHaveBeenCalledWith fields

    describe 'read contacts successfully', ->
      contact = null
      contactId = null
      contacts = null
      phoneNumbers = null
      identifyDeferred = null

      beforeEach ->
        contactId = '1234'
        phoneNumbers = [
          { value: '+19252852230'}
        ]
        contact =
          id: contactId
          name: 'Mike Pleb'
          phoneNumbers: phoneNumbers
        contacts = [contact]

        spyOn(Contacts, 'filterContacts').and.returnValue contacts
        spyOn(Contacts, 'filterNumbers').and.returnValue phoneNumbers
        spyOn(Contacts, 'formatNumbers').and.returnValue phoneNumbers

        identifyDeferred = $q.defer()
        spyOn(Contacts, 'identifyContacts').and.returnValue identifyDeferred.promise

        cordovaDeferred.resolve contacts
        scope.$apply()

      it 'should filter contacts', ->
        expect(Contacts.filterContacts).toHaveBeenCalledWith contacts

      it 'should filter contact numbers', ->
        expect(Contacts.filterNumbers).toHaveBeenCalledWith phoneNumbers

      it 'should format contact numbers', ->
        expect(Contacts.formatNumbers).toHaveBeenCalledWith phoneNumbers

      it 'should identify contacts', ->
        expect(Contacts.identifyContacts).toHaveBeenCalledWith contacts

      describe 'identify successfull', ->
        contactsObject = null

        beforeEach ->
          contactsObject = {}
          contactsObject[contactId] = contact

          spyOn(Contacts, 'saveContacts')

          identifyDeferred.resolve contactsObject
          scope.$apply()

        it 'should save the contacts', ->
          expect(Contacts.saveContacts).toHaveBeenCalledWith contactsObject

        it 'should resolve the promise', ->
          expect(resolved).toEqual true

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

  describe 'map contact id', ->
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
          { value: phone1 }
          { value: phone2 }
        ]

      contactIdMap = Contacts.mapContactIds [contact]

    it 'should return an object with all phones as keys and contact id as value', ->
      expectResult = {}
      expectResult[phone1] = contactId
      expectResult[phone2] = contactId
      expect(contactIdMap).toEqual expectResult

  describe 'identify contacts', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Contacts, 'getContactUsers').and.returnValue deferred.promise

    describe 'successfully', ->
      contactId = null
      phone = null
      userId = null
      contact = null
      identifiedContacts = null

      beforeEach ->
        contactId = '1234'
        phone = '+19252855230'
        userId = '98765'

        contact =
          id: contactId
          phoneNumbers: [
            { value: phone }
          ]

        contactCopy = angular.copy contact
        Contacts.identifyContacts([contactCopy])
          .then (_contacts_) ->
            identifiedContacts = _contacts_

        userPhone = 
          user:
            id: userId
          phone: phone
        deferred.resolve [userPhone]
        scope.$apply()

      it 'should add userId properties to contacts that have users', ->
        expectedUserId = identifiedContacts[contactId].userId
        expect(expectedUserId).toEqual userId

    describe 'not successfully :( ', ->
      rejected = null

      beforeEach ->
        rejected = false
        Contacts.identifyContacts([])
          .then (()->), () ->
            rejected = true

        deferred.reject()
        scope.$apply()

      it 'should reject the promise', ->
        expect(rejected).toEqual true

  describe 'contacts array to object', ->
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
      expectResult = {}
      expectResult[contactId] = contact
      expect(contactsObject).toEqual expectResult

  describe 'get contact users', ->
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
          { value: phone1 }
        ]
        
      phone2 = '+12345678910'
      phone3 = '+15555555555'
      contact2 =
        id: '1122'
        phoneNumbers: [
          { value: phone2 }
          { value: phone3 }
        ]

      deferred = $q.defer()
      spyOn(UserPhone, 'getFromPhones').and.returnValue {$promise : deferred.promise}

      contacts = [contact1, contact2]
      contactsCopy = angular.copy contacts

      promise = Contacts.getContactUsers contactsCopy

    it 'should check contacts to see if a users exist for every number', ->
      allPhones = [phone1, phone2, phone3]
      expect(UserPhone.getFromPhones).toHaveBeenCalledWith allPhones

    it 'should return a promise', ->
      expect(promise).toBe deferred.promise


  describe 'filter contacts', ->
    contacts = null
    formattedContacts = null
    contact1 = null

    describe 'when a contact doesn\'t have a name', ->
      filteredContacts = null

      beforeEach ->
        contact =
          name:
            formatted: '' #note: formatted may not be an empty string, test on devices
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
    
  describe 'filter numbers', ->
    phoneNumbers = null
    filteredNumbers = null

    describe 'valid numbers', ->
      beforeEach ->
        phone =
          value: '+19252852230'
        phoneNumbers = [phone]
        phoneNumbersCopy = angular.copy phoneNumbers
        filteredNumbers = Contacts.filterNumbers phoneNumbersCopy

      it 'should return valid numbers', ->
        expect(filteredNumbers).toEqual phoneNumbers

    describe 'invalid numbers', ->      

      beforeEach ->
        phone =
          value: ''
        filteredNumbers = Contacts.filterNumbers [phone]
      
      it 'should remove invalid numbers', ->
        expect(filteredNumbers).toEqual []

  describe 'format numbers', ->
    phoneNumbers = null
    formattedNumbers = null

    beforeEach ->
      phone =
        value: '9252852230'
      formattedNumbers = Contacts.formatNumbers [phone]
    
    it 'should convert numbers to E164 format', ->
      expectedPhoneFormat =
        value: '+19252852230'
      expect(formattedNumbers).toEqual [expectedPhoneFormat]

  describe 'save contacts', ->
    contact = null

    beforeEach ->
      contact =
        id: '1234'
        name:
          formatted: 'Mike Pleb'

      localStorage.set('contacts', {})
      Contacts.saveContacts [contact]

    it 'should save the contact to localStorage', ->
      savedContacts = localStorage.get 'contacts'
      expect(savedContacts).toEqual [contact]



