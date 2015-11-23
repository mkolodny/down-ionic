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

  describe 'serializing a recommended event', ->

  describe 'deserializing a recommended event', ->