require 'angular-mocks'
require 'angular-local-storage'
require 'ng-cordova'
require './contacts-module'

describe 'Contacts service', ->
  $cordovaContacts = null
  scope = null
  $q = null
  localStorage = null
  Contacts = null

  beforeEach angular.mock.module('down.contacts')

  beforeEach angular.mock.module('ngCordova.plugins.contacts')

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
    localStorage = $injector.get 'localStorageService'
    Contacts = angular.copy $injector.get('Contacts')
  )

  afterEach ->
    localStorage.clearAll()

  xdescribe 'format contacts', ->
    contacts = null

    beforeEach ->
      # Legit
      phone1 =
        value: '+19252852230'
      contact1 =
        name:
          formatted: 'Jimbo Walker'
        phoneNumbers: [phone1]

      # Invalid Number
      phone2 =
        value: '852230'
      contact2 =
        name:
          formatted: 'Bad Number Pleb'
        phoneNumbers: [phone2]

      # No Name
      phone3 =
        value: '+19252852230'
      contact3 =
        name:
          formatted: ''
        phoneNumbers: [phone3]

      contacts = [
        contact1
        contact2
        contact3
      ]

      formattedContacts = Contacts.formatContacts contacts

    it 'should remove contacts with invalid names or numbers', ->
      expect(formatContacts).toBe [contact1]

