require 'angular'
require 'angular-mocks'
require '../auth/auth-module'
require './resources-module'

describe 'event service', ->
  $httpBackend = null
  Auth = null
  Event = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    Auth = angular.copy $injector.get('Auth')
    Event = $injector.get 'Event'

    listUrl = "#{apiRoot}/events"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'creating', ->

    it 'should POST the event', ->
      event =
        title: 'bars?!?!!?'
        creatorId: 1
        canceled: false
        datetime: new Date()
        createdAt: new Date()
        updatedAt: new Date()
        place:
          name: 'B Bar & Grill'
          lat: 40.7270718
          long: -73.9919324
      postData =
        title: event.title
        creator: event.creatorId
        canceled: event.canceled
        datetime: event.datetime.getTime()
        createdAt: event.createdAt.getTime()
        updatedAt: event.updatedAt.getTime()
        place:
          name: event.place.name
          geo: "POINT(#{event.place.lat} #{event.place.long})"
      responseData = angular.extend {id: 1}, postData,
        place:
          name: postData.place.name
          geo:
            type: 'Point'
            coordinates: [
              event.place.lat
              event.place.long
            ]

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      Event.save(event).$promise.then (_response_) ->
        response = _response_
      $httpBackend.flush 1

      expectedEvent = new Event
        id: responseData.id
        title: responseData.title
        creatorId: responseData.creator
        canceled: responseData.canceled
        datetime: new Date(responseData.datetime)
        createdAt: new Date(responseData.createdAt)
        updatedAt: new Date(responseData.updatedAt)
        place:
          name: responseData.place.name
          lat: event.place.lat
          long: event.place.long
      actualEvent = new Event(response)
      expect(actualEvent).toAngularEqual expectedEvent


  describe 'sending a message', ->

    it 'should POST the message', ->
      # Mock the current user.
      Auth.user = id: 1

      event =
        id: 1
        title: 'bars?!?!!?'
        creatorId: 1
        canceled: false
        datetime: new Date()
        createdAt: new Date()
        updatedAt: new Date()
      url = "#{listUrl}/#{event.id}/messages"
      postData =
        text: 'BBar?'
        user: Auth.user.id

      $httpBackend.expectPOST url, postData
        .respond 201, null

      requestData = angular.extend {eventId: event.id}, postData
      Event.sendMessage requestData
      $httpBackend.flush 1


  describe 'canceling', ->

    it 'should DELETE the event', ->
      event =
        id: 1
        title: 'bars?!?!!?'
        creatorId: 1
        canceled: false
        datetime: new Date()
        createdAt: new Date()
        updatedAt: new Date()

      $httpBackend.expectDELETE "#{listUrl}/#{event.id}"
        .respond 200

      # TODO: Figure out how to remove excess params in a delete request so that we
      # can just call `Event.cancel event`.
      Event.cancel {id: event.id}
      $httpBackend.flush 1
