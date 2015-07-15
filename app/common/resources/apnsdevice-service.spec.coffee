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
    postData = null

    beforeEach ->
      postData =
        userId: 1
        registrationId: '1670dc75c6fa765ae1f5d16e34bccdd5fe24b9fa90dd5af81634ea557' \
          + '291a3d7'
        deviceId: '97b2517566a8479bb69e6b5d8cf6ebc8'
        name: 'iPhone, 8.3'

    describe 'on success', ->

      it 'should resolve the promise with the transformed user', ->
        responseData =
          id: 1
          user_id: postData.userId
          registration_id: postData.registrationId
          device_id: postData.deviceId
          name: postData.name

        $httpBackend.expectPOST listUrl, postData
          .respond 201, angular.toJson(responseData)

        response = null
        APNSDevice.save(postData).$promise.then (_response_) ->
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
