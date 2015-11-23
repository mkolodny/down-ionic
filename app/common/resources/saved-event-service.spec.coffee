require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'SavedEvent service', ->
  $httpBackend = null
  Event = null
  SavedEvent = null
  User = null
  listUrl = null

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    Event = $injector.get 'Event'
    SavedEvent = $injector.get 'SavedEvent'
    User = $injector.get 'User'

    listUrl = "#{apiRoot}/saved-events"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'should have a list url', ->
    expect(SavedEvent.listUrl).toBe listUrl

  ##serializeSavedEvent
  describe 'serializing a saved event', ->
    savedEvent = null

    beforeEach ->
      savedEvent =
        id: 1
        userId: 2
        eventId: 3

    describe 'with the min amount of data', ->

      beforeEach ->
        delete savedEvent.id

      it 'should serialize the saved event', ->
        expectedSavedEvent = 
          user: savedEvent.userId
          event: savedEvent.eventId
        expect(SavedEvent.serialize savedEvent).toEqual expectedSavedEvent


    describe 'with the max amount of data', ->

      it 'should serialize the saved event', ->
        expectedSavedEvent = 
          id: savedEvent.id
          user: savedEvent.userId
          event: savedEvent.eventId
        expect(SavedEvent.serialize savedEvent).toEqual expectedSavedEvent


  ##deserializeSavedEvent
  describe 'deserializing a saved event', ->
    response = null
    expectedSavedEvent = null
    user = null
    event = null

    beforeEach ->
      response =
        id: 1
      user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        firstName: 'Alan'
        lastName: 'Turing'
        username: 'tdog'
        image_url: 'https://facebook.com/profile-pic/tdog'
        location:
          type: 'Point'
          coordinates: [40.7265834, -73.9821535]
      event =
        id: 2
        title: 'bars?!??!'
        creator: 3
        canceled: false
        datetime: new Date().toISOString()
        created_at: new Date().toISOString()
        updated_at: new Date().toISOString()
        place:
          name: 'Fuku'
          geo:
            type: 'Point'
            coordinates: [40.7285098, -73.9871264]
      expectedSavedEvent =
        id: response.id
        eventId: event.id
        userId: user.id

    describe 'when the relations are ids', ->

      beforeEach ->
        response.event = event.id
        response.user = user.id

      it 'should deserialize the saved event', ->
        expect(SavedEvent.deserialize response).toEqual expectedSavedEvent


    describe 'when the relations are objects', ->

      beforeEach ->
        response.event = event
        response.user = user

      it 'should deserialize the saved event', ->
        expectedSavedEvent = angular.extend {}, expectedSavedEvent,
          event: Event.deserialize event
          user: User.deserialize user
        expect(SavedEvent.deserialize response).toEqual expectedSavedEvent


