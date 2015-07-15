require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'apnsdevice service', ->
  $httpBackend = null
  APNSDevice = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    APNSDevice = $injector.get 'APNSDevice'

    listUrl = "#{apiRoot}/apnsdevices"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'creating', ->

    it 'should POST the user', ->
      device =
        userId: 1
        registrationId: '1670dc75c6fa765ae1f5d16e34bccdd5fe24b9fa90dd5af81634ea' \
          + '557291a3d7'
        deviceId: '97b2517566a8479bb69e6b5d8cf6ebc8'
        name: 'iPhone, 8.3'
      postData =
        user_id: device.userId
        registration_id: device.registrationId
        device_id: device.deviceId
        name: device.name
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      APNSDevice.save(device).$promise.then (_response_) ->
        response = _response_
      $httpBackend.flush 1

      # TODO: encapsulate this
      expectedDevice = new APNSDevice
        id: responseData.id
        userId: responseData.user_id
        registrationId: responseData.registration_id
        deviceId: responseData.device_id
        name: responseData.name
      actualDevice = new APNSDevice(response)
      expect(actualDevice).toAngularEqual expectedDevice
