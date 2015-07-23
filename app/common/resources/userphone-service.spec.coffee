require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'userphone service', ->
  $httpBackend = null
  listUrl = null
  User = null
  UserPhone = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
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
        phone: '+1234567890'
      postData =
        user: User.serialize user
        phone: userPhone.phone
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      UserPhone.save(userPhone).$promise.then (_response_) ->
        response = _response_
      $httpBackend.flush 1

      expectedUserPhoneData = angular.extend {id: responseData.id}, userPhone
      expectedUserPhone = new UserPhone(expectedUserPhoneData)
      expect(response).toAngularEqual expectedUserPhone