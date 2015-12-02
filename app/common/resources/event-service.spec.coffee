require 'angular'
require 'angular-mocks'
require './resources-module'
require '../meteor/meteor-mocks'

describe 'event service', ->
  $filter = null
  $httpBackend = null
  $rootScope = null
  $meteor = null
  $q = null
  Event = null
  Messages = null
  User = null
  listUrl = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach inject(($injector) ->
    $filter = $injector.get '$filter'
    $httpBackend = $injector.get '$httpBackend'
    $rootScope = $injector.get '$rootScope'
    $meteor = $injector.get '$meteor'
    $q = $injector.get '$q'
    apiRoot = $injector.get 'apiRoot'
    User = $injector.get 'User'
    Event = $injector.get 'Event'

    # Mock Messages collection
    Messages =
      insert: jasmine.createSpy 'Messages.insert'
    $meteor.getCollectionByName.and.returnValue Messages

    listUrl = "#{apiRoot}/events"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'should have a list url', ->
    expect(Event.listUrl).toBe listUrl

  ##serializeEvent
  describe 'serializing an event', ->
    event = null

    beforeEach ->
      event =
        id: 1
        creatorId: 1
        title: 'bars?!?!!?'

    describe 'with the minimum amount of data', ->

      it 'should return the serialized event', ->
        expectedEvent =
          id: event.id
          creator: event.creatorId
          title: event.title
        expect(Event.serialize event).toEqual expectedEvent


    describe 'with the max amount of data', ->
      invitations = null

      beforeEach ->
        invitations = [
          to_user: 2
        ]
        event = angular.extend event,
          datetime: new Date()
          place:
            name: 'B Bar & Grill'
            lat: 40.7270718
            long: -73.9919324
          friendsOnly: true
          createdAt: new Date()
          updatedAt: new Date()

      it 'should return the serialized event', ->
        expectedEvent =
          id: event.id
          creator: event.creatorId
          title: event.title
          datetime: event.datetime.toISOString()
          place:
            name: event.place.name
            geo:
              type: 'Point'
              coordinates: [event.place.lat, event.place.long]
          friends_only: event.friendsOnly
        expect(Event.serialize event).toEqual expectedEvent


  ##deserializeEvent
  describe 'deserializing an event', ->
    response = null

    describe 'with the min amount of data', ->

      beforeEach ->
        response =
          id: 1
          creator: 1
          title: 'bars?!?!!?'
          friends_only: false
          created_at: new Date().toISOString()
          updated_at: new Date().toISOString()

      it 'should return the deserialized event', ->
        expectedEvent =
          id: response.id
          creatorId: response.creator
          title: response.title
          friendsOnly: response.friends_only
          createdAt: new Date response.created_at
          updatedAt: new Date response.updated_at
        expect(Event.deserialize response).toAngularEqual expectedEvent

    describe 'with the max amount of data', ->

      beforeEach ->
        response =
          id: 1
          creator: 1
          title: 'bars?!?!!?'
          datetime: new Date().toISOString()
          place:
            name: 'B Bar & Grill'
            geo:
              type: 'Point'
              coordinates: [40.7270718, -73.9919324]
          friends_only: false
          created_at: new Date().toISOString()
          updated_at: new Date().toISOString()

      it 'should return the deserialized event', ->
        expectedEvent =
          id: response.id
          creatorId: response.creator
          title: response.title
          datetime: new Date response.datetime
          place:
            name: response.place.name
            lat: response.place.geo.coordinates[0]
            long: response.place.geo.coordinates[1]
          friendsOnly: response.friends_only
          createdAt: new Date response.created_at
          updatedAt: new Date response.updated_at
        expect(Event.deserialize response).toAngularEqual expectedEvent


  ##resource.save
  describe 'creating', ->
    event = null
    response = null
    responseData = null
    requestData = null

    beforeEach ->
      event =
        title: 'bars?!?!!?'
        creatorId: 1
        datetime: new Date()
        place:
          name: 'B Bar & Grill'
          lat: 40.7270718
          long: -73.9919324

      requestData = Event.serialize event

    describe 'successfully', ->

      beforeEach ->
        jasmine.clock().install()
        date = new Date 1438195002656
        jasmine.clock().mockDate date

        responseData = angular.extend {id: 1}, requestData,
          place:
            name: event.place.name
            geo:
              type: 'Point'
              coordinates: [event.place.lat, event.place.long]
          created_at: new Date()
          updated_at: new Date()

        $httpBackend.expectPOST listUrl, requestData
          .respond 201, angular.toJson(responseData)

        response = null
        Event.save event
          .$promise.then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      afterEach ->
        jasmine.clock().uninstall()

      it 'should POST the event', ->
        expectedEvent = Event.deserialize responseData
        expect(response).toAngularEqual expectedEvent


    describe 'unsuccessfully', ->
      rejected = null

      beforeEach ->
        $httpBackend.expectPOST listUrl, requestData
          .respond 500, ''

        rejected = false
        Event.save event
          .$promise.then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


  ##resource::getPercentRemaining
  describe 'getting the percent remaining for an event', ->
    currentDate = null
    event = null
    result = null

    beforeEach ->
      jasmine.clock().install()
      currentDate = new Date 1438014089235
      jasmine.clock().mockDate currentDate

      event = new Event
        id: 1
        creatorId: 1
        title: 'bars?!?!!?'
        createdAt: new Date()
        updatedAt: new Date()

    afterEach ->
      jasmine.clock().uninstall()

    describe 'when the event has no datetime', ->

      beforeEach ->
        event.datetime = null
        currentHours = currentDate.getHours()
        event.createdAt = new Date().setHours currentHours-6

        result = event.getPercentRemaining()

      it 'should return the percentage', ->
        expect(result).toBe 75


    describe 'when the event has a datetime', ->

      beforeEach ->
        event.createdAt = new Date()
        event.createdAt.setDate currentDate.getDate()-2
        event.datetime = new Date()
        event.datetime.setDate currentDate.getDate()+1

        result = event.getPercentRemaining()

      it 'should return the percentage', ->
        expect(result).toBe 50


  ##resource::getEventMessage
  describe 'getting the event\'s share message', ->
    eventMessage = null
    event = null

    beforeEach ->
      event =
        id: 1
        title: 'bars?!?!!?'
        creator: 2
        canceled: false
        datetime: new Date()
        createdAt: new Date()
        updatedAt: new Date()
        place:
          name: 'B Bar & Grill'
          lat: 40.7270718
          long: -73.9919324
      event = new Event event

    describe 'when the event has all possible properties', ->

      beforeEach ->
        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        date = $filter('date') event.datetime, "EEE, MMM d 'at' h:mm a"
        message = "#{event.title} at #{event.place.name} — #{date}"
        expect(eventMessage).toBe message


    describe 'when the event has a title and place', ->

      beforeEach ->
        delete event.datetime

        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        message = "#{event.title} at #{event.place.name}"
        expect(eventMessage).toBe message


    describe 'when the event has a title and datetime', ->

      beforeEach ->
        delete event.place

        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        date = $filter('date') event.datetime, "EEE, MMM d 'at' h:mm a"
        message = "#{event.title} — #{date}"
        expect(eventMessage).toBe message


    describe 'when the event only has a title', ->

      beforeEach ->
        delete event.place
        delete event.datetime

        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        expect(eventMessage).toBe event.title

