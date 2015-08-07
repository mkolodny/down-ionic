require 'angular'
require 'angular-mocks'
require '../auth/auth-module'
require './resources-module'

describe 'event service', ->
  $httpBackend = null
  Asteroid = null
  Auth = null
  Event = null
  Invitation = null
  Messages = null
  User = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module(($provide) ->
    # Mock a logged in user.
    Auth =
      user:
        id: 1
        name: 'Alan Turing'
        imageUrl: 'http://facebook.com/profile-pic/tdog'
    $provide.value 'Auth', Auth

    # Mock Asteroid.
    Messages =
      insert: jasmine.createSpy 'Messages.insert'
    Asteroid =
      getCollection: jasmine.createSpy('Asteroid.getCollection').and.returnValue \
          Messages
    $provide.value 'Asteroid', Asteroid
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

  it 'should have a list url', ->
    expect(Event.listUrl).toBe listUrl

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
    event = null
    text = null
    url = null
    requestData = null

    beforeEach ->
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
      text = 'I\'m in love with a robot.'
      url = "#{listUrl}/#{event.id}/messages"
      requestData = {text: text}

    describe 'successfully', ->
      resolved = false

      beforeEach ->
        $httpBackend.expectPOST url, requestData
          .respond 201, null

        Event.sendMessage(event, text).then ->
          resolved = true
        $httpBackend.flush 1

      it 'should resolve the promise', ->
        expect(resolved).toBe true

      it 'should get the messages collection', ->
        expect(Asteroid.getCollection).toHaveBeenCalledWith 'messages'

      it 'should save the message in the meteor server', ->
        message =
          creator:
            id: Auth.user.id
            name: Auth.user.name
            imageUrl: Auth.user.imageUrl
          text: text
          eventId: event.id
          type: 'text'
        expect(Messages.insert).toHaveBeenCalledWith message


    describe 'unsuccessfully', ->
      rejected = false

      beforeEach ->
        $httpBackend.expectPOST url, requestData
          .respond 500, null

        Event.sendMessage(event, text).then null, ->
          rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


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
