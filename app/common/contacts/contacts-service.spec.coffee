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
      phone: '+19252852235'
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
        expect(Contacts.identifyContacts).toHaveBeenCalledWith contacts

      describe 'and contacts are identified successfully', ->
        contacts = null

        beforeEach ->
          contacts = [contact]
          spyOn Contacts, 'saveContacts'

          # Since this method is called after we get the contacts from Cordova, we
          #   need to reset the spy.
          Contacts.saveContacts.calls.reset()

          # We also need to reset notification since that gets set after finding
          #   contacts resolves.
          notification = null

          identifyDeferred.resolve contacts
          scope.$apply()

        it 'should save the contacts', ->
          expect(Contacts.saveContacts).toHaveBeenCalledWith contacts

        it 'should set hasRequestedContacts to true', ->
          expect(localStorage.get 'hasRequestedContacts').toEqual true

        it 'should resolve the promise with the contacts', ->
          expect(response).toEqual contacts


      describe 'identify error', ->

        beforeEach ->
          identifyDeferred.reject()
          scope.$apply()

        it 'should reject the promise', ->
          expect(error.code).toEqual 'IDENTIFY_FAILED'


    describe 'read contacts failed', ->

      beforeEach ->
        cordovaError =
          code: 'blah'

        cordovaDeferred.reject cordovaError
        scope.$apply()

      it 'should reject the promise', ->
        expect(error.code).toEqual 'PERMISSION_DENIED_ERROR'


  describe 'identifying contacts', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Contacts, 'toUsers').and.returnValue deferred.promise

    describe 'successfully', ->
      contactId = null
      userPhone = null
      users = null
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
        contacts = [contactCopy]
        Contacts.identifyContacts contacts
          .then (_contacts_) ->
            identifiedContacts = _contacts_

        user =
          id: 98765
        users = {}
        users[user.id] = user
        deferred.resolve users
        scope.$apply()

      it 'should return an object of users', ->
        expect(identifiedContacts).toEqual users


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


  describe 'getting the users associated with contacts', ->
    phone1 = null
    phone2 = null
    phone3 = null
    contact1 = null
    contact2 = null
    contacts = null
    rejected = null
    deferred = null
    users = null

    beforeEach ->
      phone1 = '+19252852230'
      contact1 =
        id: '1234'
        name:
          formatted: 'Ada Lovelace'
        phoneNumbers: [
          value: phone1
        ]

      phone2 = '+12345678910'
      phone3 = '+15555555555'
      contact2 =
        id: '1122'
        name:
          formatted: 'Linus Torvalds'
        phoneNumbers: [
          value: phone2
        ,
          value: phone3
        ]

      deferred = $q.defer()
      spyOn(UserPhone, 'getFromContacts').and.returnValue
        $promise: deferred.promise

      contacts = [contact1, contact2]
      rejected = false
      Contacts.toUsers contacts
        .then (_users_) ->
          users = _users_
        , ->
          rejected = true

    it 'should check contacts to see if users exist', ->
      contacts = [
        name: contact1.name.formatted
        phone: phone1
      ,
        name: contact2.name.formatted
        phone: phone2
      ,
        name: contact2.name.formatted
        phone: phone3
      ]
      expect(UserPhone.getFromContacts).toHaveBeenCalledWith contacts

    describe 'when the userphones return successfully', ->
      userPhone = null
      userPhones = null

      beforeEach ->
        userPhone =
          user:
            id: 1
            name: 'Tony Soprano'
          phone: '+12036227310'
        userPhones = [userPhone]
        spyOn(Contacts, 'filterUserPhones').and.returnValue userPhones

        deferred.resolve userPhones
        scope.$apply()

      it 'should filter users', ->
        expect(Contacts.filterUserPhones).toHaveBeenCalledWith userPhones, contacts

      it 'should resolve the promise with the users', ->
        user = userPhone.user
        expectedUsers = {}
        expectedUsers[user.id] = user
        expect(users).toEqual expectedUsers


    describe 'when the userphone call is unsuccessful', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should reject the promise', ->
        expect(rejected).toBe true


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

      it 'should return the contact', ->
        expect(filteredContacts).toEqual contacts


    describe 'when a contact has null phone numbers', ->

      beforeEach ->
        contact =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: null
        filteredContacts = Contacts.filterContacts [contact]

      it 'should remove the contact', ->
        expect(filteredContacts).toEqual []


    describe 'when a contact has no phone numbers', ->

      beforeEach ->
        contact =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: []
        filteredContacts = Contacts.filterContacts [contact]

      it 'should remove the contact', ->
        expect(filteredContacts).toEqual []


    describe 'when a contact is the logged in user', ->

      beforeEach ->
        contact =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: [
            value: Auth.phone
          ,
            value: '+12036227310'
          ]
        filteredContacts = Contacts.filterContacts [contact]

      it 'should remove the contact', ->
        expect(filteredContacts).toEqual []


    describe 'when two contacts have the same phone number', ->
      contact1 = null

      beforeEach ->
        phone = '+12036227310'
        contact1 =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: [
            value: phone
          ]
        contact2 =
          name:
            formatted: 'Jimbo Walker'
          phoneNumbers: [
            value: phone
          ]
        filteredContacts = Contacts.filterContacts [contact1, contact2]

      it 'should only return the first contact', ->
        expect(filteredContacts).toEqual [contact1]



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


    describe 'with two of the same numbers', ->
      phone = null

      beforeEach ->
        phone =
          value: '+19252852230'
        phoneNumbers = [phone, phone]
        phoneNumbersCopy = angular.copy phoneNumbers
        filteredNumbers = Contacts.filterNumbers phoneNumbersCopy

      it 'should only return one of a certain number', ->
        expect(filteredNumbers).toEqual [phone]


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


  describe 'filtering userphones', ->
    homePhone = null
    mobilePhone = null
    filteredUserPhones = null

    beforeEach ->
      homePhone = '+12036227310'
      mobilePhone = '+14388833650'

    describe 'when a user has a username', ->
      userPhoneWithUsername = null

      beforeEach ->
        contacts = [
          id: 1
          phoneNumbers: [
            type: 'home' # TODO: test lowercase
            value: homePhone
          ,
            type: 'mobile'
            value: mobilePhone
          ]
        ]

        userPhoneWithUsername =
          user:
            id: 1
            username: 'trixy'
          phone: homePhone
        userPhoneWithoutUsername =
          user:
            id: 2
            username: null
          phone: mobilePhone
        userPhones = [userPhoneWithUsername, userPhoneWithoutUsername]
        filteredUserPhones = Contacts.filterUserPhones userPhones, contacts

      it 'should return the userphone for the user with a username', ->
        expect(filteredUserPhones).toEqual [userPhoneWithUsername]


    describe 'when a user has a mobile phone', ->
      userPhoneWithMobile = null

      beforeEach ->
        contacts = [
          id: 1
          phoneNumbers: [
            type: 'home' # TODO: test lowercase
            value: homePhone
          ,
            type: 'mobile'
            value: mobilePhone
          ]
        ]

        userPhoneWithHome =
          user:
            id: 1
            username: null
          phone: homePhone
        userPhoneWithMobile =
          user:
            id: 2
            username: null
          phone: mobilePhone
        userPhones = [userPhoneWithHome, userPhoneWithMobile]
        filteredUserPhones = Contacts.filterUserPhones userPhones, contacts

      it 'should return the userphone for the user with a mobile phone', ->
        expect(filteredUserPhones).toEqual [userPhoneWithMobile]


    describe 'when no users have usernames of mobile phones', ->
      userPhone1 = null

      beforeEach ->
        contacts = [
          id: 1
          phoneNumbers: [
            type: 'home' # TODO: test lowercase
            value: homePhone
          ,
            type: 'home'
            value: mobilePhone
          ]
        ]

        userPhone1 =
          user:
            id: 1
            username: null
          phone: homePhone
        userPhone2 =
          user:
            id: 2
            username: null
          phone: mobilePhone
        userPhones = [userPhone1, userPhone2]
        filteredUserPhones = Contacts.filterUserPhones userPhones, contacts

      it 'should return the first userphone', ->
        expect(filteredUserPhones).toEqual [userPhone1]


  describe 'saving contacts', ->
    contacts = null

    beforeEach ->
      contact =
        id: '1234'
        name:
          formatted: 'Mike Pleb'
      contacts = {}
      contacts[contact.id] = contact

      localStorage.set 'contacts', {}
      Contacts.saveContacts contacts

    it 'should save the contacts to localStorage', ->
      savedContacts = localStorage.get 'contacts'
      expect(savedContacts).toEqual contacts
