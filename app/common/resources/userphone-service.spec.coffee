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
      expectedUserPhone = new UserPhone expectedUserPhoneData
      expect(response).toAngularEqual expectedUserPhone


  describe 'getting from contacts', ->
    url = null
    name = null
    phone = null
    contacts = null
    requestData = null

    beforeEach ->
      url = "#{listUrl}/contacts"
      name = 'Alan Turing'
      phone = '+12036227310'
      contacts = [
        name: name
        phone: phone
      ]
      requestData =
        contacts: contacts

    describe 'successfully', ->
      user = null
      response = null

      beforeEach ->
        user =
          id: 1
          email: 'aturing@gmail.com'
          name: name
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

        UserPhone.getFromContacts contacts
          .$promise.then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      it 'should return the userphones', ->
        userphone =
          user: User.deserialize user
          phone: phone
        expect(response).toAngularEqual [userphone]
