require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'SavedEvent service', ->
  $httpBackend = null
  SavedEvent = null
  listUrl = null

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    SavedEvent = $injector.get 'SavedEvent'

    listUrl = "#{apiRoot}/saved-events"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'should have a list url', ->
    expect(SavedEvent.listUrl).toBe listUrl

  describe 'serializing a saved event', ->

  describe 'deserializing a saved event', ->
