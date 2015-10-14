require 'angular'
require 'angular-mocks'
require '../ng-cordova/sqlite.js'
require './local-db-module'

describe 'LocalDB service', ->
  $cordovaSQLite = null
  $rootScope = null
  $q = null
  LocalDB = null

  beforeEach angular.mock.module('down.localDB')

  beforeEach angular.mock.module('ngCordova.plugins.sqlite')

  # beforeEach angular.mock.module(($provide) ->
  #   db = {}
  #   pouchDB = jasmine.createSpy('pouchDB').and.callFake ->
  #     db
  #   $provide.value 'pouchDB', pouchDB
  #   return
  # )

  beforeEach inject(($injector) ->
    $cordovaSQLite = $injector.get '$cordovaSQLite'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    LocalDB = $injector.get 'LocalDB'
  )

  describe 'initilizing the database', ->
    db = null
    deferred = null
    resolved = null
    rejected = null

    beforeEach ->
      db = 'db'
      spyOn($cordovaSQLite, 'openDB').and.returnValue db

      deferred = $q.defer()
      spyOn($cordovaSQLite, 'execute').and.returnValue deferred.promise
      
      LocalDB.init().then ->
        resolved = true
      , ->
        rejected = true

    it 'should initilize the database', ->
      expect($cordovaSQLite.openDB).toHaveBeenCalledWith
        name: 'rallytap.db'
        location: 2
       
    it 'should set the db on the service', ->
      expect(LocalDB.db).toBe db

    it 'should create the localStorage table if it doesn\'t exist', ->
      query = 'CREATE TABLE IF NOT EXISTS local_storage (key string primary key, value text)'
      expect($cordovaSQLite.execute).toHaveBeenCalledWith LocalDB.db, query

    describe 'table created successfully', ->

      beforeEach ->
        deferred.resolve()
        $rootScope.$apply()

      it 'should resolve the promise', ->
        expect(resolved).toBe true


    describe 'on error', ->

      beforeEach ->
        deferred.reject()
        $rootScope.$apply()

      it 'should reject the promise', ->
        expect(rejected).toBe true


  describe 'getting a value', ->
    promise = null
    key = null
    result = null

    beforeEach ->
      promise = 'promise'
      spyOn($cordovaSQLite, 'execute').and.returnValue promise
      key = 'someKey'
      result = LocalDB.get key

    it 'should query local_storage by key', ->
      query = "SELECT * FROM local_storage WHERE key=#{key} LIMIT 1"
      expect($cordovaSQLite.execute).toHaveBeenCalledWith LocalDB.db, query

    it 'should return the $cordovaSQLite.execute promise', ->
      expect(result).toBe promise


  describe 'setting a value', ->
    promise = null
    key = null
    value = null
    result = null

    beforeEach ->
      promise = 'promise'
      spyOn($cordovaSQLite, 'execute').and.returnValue promise
      key = 'someKey'
      value =
        id: 1
        name: 'Mike Pleb'
        friends: 'none'
      result = LocalDB.set key, value

    it 'should query local_storage by key', ->
      value = angular.toJson value
      query = "INSERT OR REPLACE INTO local_storage (key, value) VALUES (#{key}, #{value})"
      expect($cordovaSQLite.execute).toHaveBeenCalledWith LocalDB.db, query

    it 'should return the $cordovaSQLite.execute promise', ->
      expect(result).toBe promise