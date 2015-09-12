require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'GCMDevice service', ->
  $httpBackend = null
  GCMDevice = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    GCMDevice = $injector.get 'GCMDevice'

    listUrl = "#{apiRoot}/devices/gcm"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'creating', ->

    it 'should POST the device', ->
      device =
        userId: 1
        registrationId: '1670dc75c6fa765ae1f5d16e34bccdd5fe24b9fa90dd5af81634ea' \
          + '557291a3d7'
        deviceId: '97b2517566a8479bb69e6b5d8cf6ebc8'
        name: 'Passion, 2.2'
      postData =
        user: device.userId
        registration_id: device.registrationId
        device_id: device.deviceId
        name: device.name
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      GCMDevice.save device
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedDeviceData = angular.extend {id: responseData.id}, device
      expectedDevice = new GCMDevice(expectedDeviceData)
      expect(response).toAngularEqual expectedDevice
