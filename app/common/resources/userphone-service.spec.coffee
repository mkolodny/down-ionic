require 'angular'
require 'angular-local-storage'
require 'angular-mocks'
require './resources-module'

describe 'userphone service', ->
  $httpBackend = null
  localStorage = null
  listUrl = null
  User = null
  UserPhone = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module(($provide) ->
    Auth =
      phone: '+19252852230'
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    localStorage = $injector.get 'localStorageService'
    User = $injector.get 'User'
    UserPhone = $injector.get 'UserPhone'

    listUrl = "#{apiRoot}/userphones"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'creating', ->

    it 'should POST the userphone', ->
      user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pic/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535
      userPhone =
        user: user
        phone: '+12345678901'
      postData =
        user: User.serialize user
        phone: userPhone.phone
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      UserPhone.save userPhone
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedUserPhoneData = angular.extend {id: responseData.id}, userPhone
      expectedUserPhone = new UserPhone(expectedUserPhoneData)
      expect(response).toAngularEqual expectedUserPhone


  describe 'creating from a contact', ->
    contact = null
    intlPhone = null
    requestData = null
    url = null
    user = null

    beforeEach ->
      contact =
        id: 1
        name:
          formatted: 'Alan Turing'
          givenName: 'Alan'
          familyName: 'Turing'
        phoneNumbers: [
          type: 'mobile'
          value: '2036227310'
          pref: true
        ]
      intlPhone = '+12036227310'
      requestData =
        name: contact.name.formatted
        #first_name: contact.name.givenName
        #last_name: contact.name.familyName
        phone: intlPhone
      url = "#{listUrl}/contact"

    describe 'successfully', ->
      response = null

      beforeEach ->
        # Mock the contacts having been saved in local storage.
        contacts =
          "#{contact.id}": contact
        localStorage.set 'contacts', contacts

        user =
          id: 1
          email: 'aturing@gmail.com'
          name: contact.name.formatted
          #first_name: contact.name.givenName
          #last_name: contact.name.familyName
          username: 'tdog'
          image_url: 'https://facebook.com/profile-pic/tdog'
          location:
            type: 'Point'
            coordinates: [40.7265834, -73.9821535]
        responseData =
          user: user
          phone: intlPhone
        $httpBackend.expectPOST url, requestData
          .respond 201, angular.toJson(responseData)

        UserPhone.create(contact).then (_response_) ->
          response = _response_
        $httpBackend.flush 1

      it 'should POST the contact', ->
        data =
          contact: contact
          userphone:
            user: User.deserialize user
            phone: intlPhone
        expect(response).toAngularEqual data

      it 'should update the contact in local storage', ->
        contacts = localStorage.get 'contacts'
        updatedContact = angular.extend {}, contact,
          user: User.deserialize user
        updatedContacts =
          "#{contact.id}": updatedContact
        expect(contacts).toAngularEqual updatedContacts


    describe 'unsuccessfully', ->
      rejected = false

      beforeEach ->
        $httpBackend.expectPOST url, requestData
          .respond 500, ''

        UserPhone.create(contact).then null, ->
          rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


    xdescribe 'when the phone number is invalid', ->


  describe 'getting from phones', ->
    url = null
    phone = null
    phones = null
    requestData = null

    beforeEach ->
      url = "#{listUrl}/phones"
      phone = '+12036227310'
      phones = [phone]
      requestData =
        phones: phones

    describe 'successfully', ->
      user = null
      response = null

      beforeEach ->
        user =
          id: 1
          email: 'aturing@gmail.com'
          name: 'Alan Turing'
          username: 'tdog'
          image_url: 'https://facebook.com/profile-pic/tdog'
          location:
            type: 'Point'
            coordinates: [40.7265834, -73.9821535]
        responseData = [
          user: user
          phone: phone
        ]
        $httpBackend.expectPOST url, requestData
          .respond 200, angular.toJson(responseData)

        UserPhone.getFromPhones phones
          .$promise.then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      it 'should return the userphones', ->
        userphone =
          user: User.deserialize user
          phone: phone
        expect(response).toAngularEqual [userphone]
