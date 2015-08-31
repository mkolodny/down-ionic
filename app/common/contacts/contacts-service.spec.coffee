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

    it 'should get contacts name and phone numbers', ->
      options =
        filter: ''
        multiple: true
        fields: [
          'id'
          'name'
          'phoneNumbers'
        ]
      expect($cordovaContacts.find).toHaveBeenCalledWith options

    describe 'when contacts are read successfully', ->
      contact = null
      contactId = null
      contacts = null
      contactsDict = null
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
        contactsDict = Contacts.contactArrayToDict contacts

        spyOn(Contacts, 'filterContacts').and.returnValue contacts
        spyOn(Contacts, 'filterNumbers').and.returnValue phoneNumbers
        spyOn(Contacts, 'formatNumbers').and.returnValue phoneNumbers

        identifyDeferred = $q.defer()
        spyOn(Contacts, 'identifyContacts').and.returnValue \
            identifyDeferred.promise

        cordovaDeferred.resolve contacts
        scope.$apply()

      it 'should filter contacts', ->
        expect(Contacts.filterContacts).toHaveBeenCalledWith contacts

      it 'should filter numbers', ->
        expect(Contacts.filterNumbers).toHaveBeenCalledWith phoneNumbers

      it 'should format numbers', ->
        expect(Contacts.formatNumbers).toHaveBeenCalledWith phoneNumbers

      it 'should identify contacts', ->
        expect(Contacts.identifyContacts).toHaveBeenCalledWith contactsDict

      describe 'and contacts are identified successfully', ->
        contactsDict = null

        beforeEach ->
          contactsDict = {"#{contactId}": contact}
          spyOn Contacts, 'saveContacts'

          # Since this method is called after we get the contacts from Cordova, we
          #   need to reset the spy.
          Contacts.saveContacts.calls.reset()

          # We also need to reset notification since that gets set after finding
          #   contacts resolves.
          notification = null

          identifyDeferred.resolve contactsDict
          scope.$apply()

        it 'should save the contacts', ->
          expect(Contacts.saveContacts).toHaveBeenCalledWith contactsDict

        it 'should resolve the promise with the contacts', ->
          expect(response).toEqual contactsDict


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

      it 'should set hasRequestedContacts to true', ->
        expect(localStorage.get 'hasRequestedContacts').toEqual true


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
        contacts = {"#{contactCopy.id}": contactCopy}
        Contacts.identifyContacts contacts
          .then (_contacts_) ->
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
    contactsDict = null

    beforeEach ->
      contactId = '12345'
      contact =
        id: contactId
        name: 'Mike Pleb'
      contactsDict = Contacts.contactArrayToDict [contact]

    it 'should return an object with key contact id and value contact', ->
      expect(contactsDict).toEqual {"#{contactId}": contact}


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

      contactsDict = {}
      contactsDict[contact1.id] = contact1
      contactsDict[contact2.id] = contact2
      contactsDictCopy = angular.copy contactsDict

      promise = Contacts.getContactUsers contactsDictCopy

    it 'should check contacts to see if a users exist for every number', ->
      allPhones = [phone2, phone3, phone1]
      expect(UserPhone.getFromPhones).toHaveBeenCalledWith allPhones

    it 'should return a promise', ->
      expect(promise).toBe deferred.promise


  describe 'filtering contacts', ->
    filteredContacts = null

    describe 'when a contact doesn\'t have a name', ->

      beforeEach ->
        contact =
          name:
            formatted: '' # NOTE: formatted may not be an empty string,
                          #   test on devices.
          phoneNumbers: [
            value: '+19252852230'
          ]
        filteredContacts = Contacts.filterContacts [contact]

      it 'should remove contacts with no names', ->
        expect(filteredContacts).toEqual []


    describe 'when a contact has a name and phone numbers', ->
      contacts = null

      beforeEach ->
        contact =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: [
            value: '+19252852230'
          ]
        contacts = [contact]
        contactsCopy = angular.copy contacts
        filteredContacts = Contacts.filterContacts contactsCopy

      it 'should return contacts with names', ->
        expect(filteredContacts).toEqual contacts


    describe 'when a contact has null phone numbers', ->

      beforeEach ->
        contact =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: null
        filteredContacts = Contacts.filterContacts [contact]

      it 'should remove contacts with null phone numbers', ->
        expect(filteredContacts).toEqual []


    describe 'when a contact has no phone numbers', ->

      beforeEach ->
        contact =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: []
        filteredContacts = Contacts.filterContacts [contact]

      it 'should remove contacts with no phone numbers', ->
        expect(filteredContacts).toEqual []


  describe 'filtering numbers', ->
    phoneNumbers = null
    filteredNumbers = null

    describe 'with valid numbers', ->

      beforeEach ->
        phone =
          value: '+19252852230'
        phoneNumbers = [phone]
        phoneNumbersCopy = angular.copy phoneNumbers
        filteredNumbers = Contacts.filterNumbers phoneNumbersCopy

      it 'should return the numbers', ->
        expect(filteredNumbers).toEqual phoneNumbers


    describe 'with invalid numbers', ->

      beforeEach ->
        phone =
          value: ''
        filteredNumbers = Contacts.filterNumbers [phone]

      it 'should remove invalid numbers', ->
        expect(filteredNumbers).toEqual []


    describe 'with null numbers', ->

      beforeEach ->
        filteredNumbers = Contacts.filterNumbers null

      it 'should return an empty array', ->
        expect(filteredNumbers).toEqual []


  describe 'formatting numbers', ->
    phoneNumbers = null
    formattedNumbers = null

    describe 'when numbers is defined', ->

      beforeEach ->
        phone =
          value: '9252852230'
        formattedNumbers = Contacts.formatNumbers [phone]

      it 'should convert numbers to E164 format', ->
        expectedPhoneFormat =
          value: '+19252852230'
        expect(formattedNumbers).toEqual [expectedPhoneFormat]


    describe 'when numbers is null', ->

      beforeEach ->
        formattedNumbers = Contacts.formatNumbers null

      it 'should return null', ->
        expect(formattedNumbers).toEqual null


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
