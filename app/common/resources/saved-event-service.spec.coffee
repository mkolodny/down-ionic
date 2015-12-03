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
    friend1 = null
    friend2 = null
    totalNumInterested = null
    event = null

    beforeEach ->
      user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        first_name: 'Alan'
        last_name: 'Turing'
        username: 'tdog'
        image_url: 'https://facebook.com/profile-pic/tdog'
        location:
          type: 'Point'
          coordinates: [40.7265834, -73.9821535]
      friend1 = angular.extend {}, user
      friend1.id = 2
      friend2 = angular.extend {}, user
      friend2.id = 3
      totalNumInterested = 2
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

      response =
        id: 1
        event: event.id
        user: user.id
        interested_friends: [friend1, friend2]
        total_num_interested: totalNumInterested
        created_at: new Date().toISOString()

      expectedSavedEvent =
        id: response.id
        eventId: event.id
        userId: user.id
        totalNumInterested: totalNumInterested
        interestedFriends: [ 
          User.deserialize friend1
        ,
          User.deserialize friend2
        ]
        createdAt: new Date response.created_at

    describe 'with the minimum amount of data', ->

      beforeEach ->
        delete response.interested_friends
        delete response.total_num_interested

        delete expectedSavedEvent.interestedFriends
        delete expectedSavedEvent.totalNumInterested

      it 'should deserialize the event', ->
        expect(SavedEvent.deserialize response).toEqual expectedSavedEvent


    describe 'when the relations are ids', ->

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

  ##resource.save
  describe 'creating', ->

    it 'should POST the user', ->
      savedEvent =
        id: 1
        userId: 2
        eventId: 3
      postData = SavedEvent.serialize savedEvent
      responseData = angular.extend postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      SavedEvent.save savedEvent
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedSavedEventData = angular.extend
        id: responseData.id
        authtoken: responseData.authtoken
      , savedEvent
      expectedSavedEvent = new SavedEvent expectedSavedEventData
      expect(response).toAngularEqual expectedSavedEvent

  ##resource.query
  describe 'querying', ->

    it 'should GET the saved events', ->
      responseData = [
        id: 1
        event: 2
        user: 2
      ]

      $httpBackend.expectGET listUrl
        .respond 200, angular.toJson(responseData)

      response = null
      SavedEvent.query().$promise
        .then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedSavedEventData = SavedEvent.deserialize responseData[0]
      expectedSavedEvents = [new SavedEvent expectedSavedEventData]
      expect(response).toAngularEqual expectedSavedEvents


