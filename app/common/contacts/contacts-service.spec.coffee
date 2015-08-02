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

    beforeEach ->
      fields = ['id', 'name', 'phoneNumbers']
      localStorage.set('hasRequestedContacts', false)
      Contacts.getContacts()

    it 'should set hasRequestedContacts to true', ->
      expect(localStorage.get('hasRequestedContacts')).toEqual true

    it 'should get contacts name and phone numbers', ->
      expect($cordovaContacts.find).toHaveBeenCalledWith fields

  describe 'identify contacts', ->
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

      promise = Contacts.identifyContacts contactsCopy

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



