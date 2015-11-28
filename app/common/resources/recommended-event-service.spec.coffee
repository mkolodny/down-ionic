require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'RecommendedEvent service', ->
  $httpBackend = null
  RecommendedEvent = null
  listUrl = null

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    RecommendedEvent = $injector.get 'RecommendedEvent'

    listUrl = "#{apiRoot}/recommended-events"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'should have a list url', ->
    expect(RecommendedEvent.listUrl).toBe listUrl

  # describe 'serializing a recommended event', ->
    # Not needed because client can't save recommended events

  ##deserializeRecommendedEvent
  describe 'deserializing a recommended event', ->
    response = null

    beforeEach ->
      response =
        id: 1
        title: 'Bars?!?!?'
        place:
          name: 'B Bar & Grill'
          geo:
            type: 'Point'
            coordinates: [40.7270718, -73.9919324]
        datetime: new Date().toISOString()

    describe 'with the min amount of data', ->

      beforeEach ->
        delete response.place
        delete response.datetime

      it 'should return the deserialized recommended event', ->
        expectedRecommendedEvent =
          id: response.id
          title: response.title
        expect(RecommendedEvent.deserialize response).toAngularEqual expectedRecommendedEvent

    describe 'with the max amount of data', ->

      it 'should return the deserialized recommended event', ->
        expectedRecommendedEvent =
          id: response.id
          title: response.title
          datetime: new Date response.datetime
          place:
            name: response.place.name
            lat: response.place.geo.coordinates[0]
            long: response.place.geo.coordinates[1]
        expect(RecommendedEvent.deserialize response).toAngularEqual expectedRecommendedEvent

  ##resource.query
  describe 'querying', ->

    it 'should GET the recommended events', ->
      responseData = [
        id: 1
        title: 'BARS!?!?!?'
      ]

      $httpBackend.expectGET listUrl
        .respond 200, angular.toJson(responseData)

      response = null
      RecommendedEvent.query().$promise
        .then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedRecommendedEventData = RecommendedEvent.deserialize responseData[0]
      expectedRecommendedEvents = [new RecommendedEvent expectedRecommendedEventData]
      expect(response).toAngularEqual expectedRecommendedEvents



