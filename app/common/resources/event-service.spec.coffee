require 'angular'
require 'angular-mocks'
require '../auth/auth-module'
require './resources-module'

describe 'event service', ->
  $httpBackend = null
  Auth = null
  Event = null
  Invitation = null
  User = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module(($provide) ->
    # Mock a logged in user.
    Auth =
      user:
        id: 1
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    User = $injector.get 'User'
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'

    listUrl = "#{apiRoot}/events"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'serializing an event', ->

    it 'should return the serialized event', ->
      event =
        id: 1
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
      expectedEvent =
        id: event.id
        title: event.title
        creator: event.creatorId
        canceled: event.canceled
        datetime: new Date(event.datetime).getTime()
        created_at: new Date(event.createdAt).getTime()
        updated_at: new Date(event.updatedAt).getTime()
        place:
          name: event.place.name
          geo:
            type: 'Point'
            coordinates: [event.place.lat, event.place.long]
      expect(Event.serialize event).toEqual expectedEvent


  describe 'deserializing an event', ->

    it 'should return the deserialized event', ->
      response =
        id: 1
        title: 'bars?!?!!?'
        creator: 1
        canceled: false
        datetime: new Date().getTime()
        created_at: new Date().getTime()
        updated_at: new Date().getTime()
        place:
          name: 'B Bar & Grill'
          geo:
            type: 'Point'
            coordinates: [40.7270718, -73.9919324]
      expectedEvent =
        id: response.id
        title: response.title
        creatorId: response.creator
        canceled: response.canceled
        datetime: new Date(response.datetime)
        createdAt: new Date(response.created_at)
        updatedAt: new Date(response.updated_at)
        place:
          name: response.place.name
          lat: response.place.geo.coordinates[0]
          long: response.place.geo.coordinates[1]
      expect(Event.deserialize response).toEqual expectedEvent


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
      postData = Event.serialize event
      responseData = angular.extend {id: 1}, postData,
        place:
          name: event.place.name
          geo:
            type: 'Point'
            coordinates: [event.place.lat, event.place.long]

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      Event.save event
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedEventData = angular.extend {id: responseData.id}, event
      expectedEvent = new Event expectedEventData
      expect(response).toAngularEqual expectedEvent


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
