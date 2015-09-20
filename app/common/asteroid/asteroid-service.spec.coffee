require 'angular'
require 'angular-mocks'
require './asteroid-module'
AsteroidClient = require 'asteroid/dist/asteroid.cordova.js'

describe 'Asteroid service', ->
  Asteroid = null

  beforeEach angular.mock.module('down.asteroid')

  beforeEach inject(($injector) ->
    Asteroid = angular.copy $injector.get('Asteroid')
  )

  it 'should init an Asteroid instance', ->
    expect(Asteroid._instance).toEqual jasmine.any(AsteroidClient)
    expect(Asteroid._instance._host).toBe "https://#{Asteroid.meteorHost}"

  describe 'logging in', ->
    promise = null
    result = null
    username = null
    password = null

    beforeEach ->
      promise = 'promise'
      spyOn(Asteroid._instance, 'loginWithPassword').and.returnValue promise

      username = 1
      password = 'asdfkjhasdflk'

      result = Asteroid.login username, password

    it 'should login the current user', ->
      expect(Asteroid._instance.loginWithPassword).toHaveBeenCalledWith \
          "#{username}", password # set username to a string because Meteor

    it 'should return a promise', ->
      expect(result).toBe promise


  describe 'subscribing', ->
    subscription = null
    name = null
    param1 = null
    param2 = null
    result = null

    beforeEach ->
      subscription = 'subscription'
      spyOn(Asteroid._instance, 'subscribe').and.returnValue subscription

      name = 'name'
      param1 = 'param1'
      param2 = 'param2'
      result = Asteroid.subscribe name, param1, param2

    it 'should subscribe to the name', ->
      expect(Asteroid._instance.subscribe).toHaveBeenCalledWith name, param1, \
            param2

    it 'should return the subscription', ->
      expect(result).toBe subscription


  describe 'getting a collection', ->
    collection = null
    name = null
    result = null

    beforeEach ->
      collection = 'collection'
      spyOn(Asteroid._instance, 'getCollection').and.returnValue collection

      name = 'name'
      result = Asteroid.getCollection name

    it 'should get the collection', ->
      expect(Asteroid._instance.getCollection).toHaveBeenCalledWith name

    it 'should return the collection', ->
      expect(result).toBe collection


  describe 'calling a method', ->
    promise = null
    name = null
    param1 = null
    param2 = null
    result = null

    beforeEach ->
      promise = 'promise'
      spyOn(Asteroid._instance, 'call').and.returnValue promise

      name = 'name'
      param1 = 'param1'
      param2 = 'param2'
      result = Asteroid.call name, param1, param2

    it 'should subscribe to the name', ->
      expect(Asteroid._instance.call).toHaveBeenCalledWith name, param1, \
            param2

    it 'should return the promise', ->
      expect(result).toBe promise
