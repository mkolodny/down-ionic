require 'angular'
require 'angular-mocks'
window.PouchDB = require 'pouchdb'
# require './angular-pouchdb'
require './local-db-module'

xdescribe 'LocalDB service', ->
  $rootScope = null
  LocalDB = null
  pouchDB = null
  $timeout = null

  beforeEach angular.mock.module('down.localDB')

  # beforeEach angular.mock.module('pouchdb')


  # beforeEach angular.mock.module(($provide) ->
  #   db = {}
  #   pouchDB = jasmine.createSpy('pouchDB').and.callFake ->
  #     db
  #   $provide.value 'pouchDB', pouchDB
  #   return
  # )

  beforeEach inject(($injector) ->
    # pouchDB = $injector.get 'pouchDB'
    $rootScope = $injector.get '$rootScope'
    LocalDB = $injector.get 'LocalDB'
    $timeout = $injector.get '$timeout'
  )

  describe 'initilizing the database', ->
    db = null

    beforeEach ->
      db = 'db'
      spyOn(LocalDB, 'pouchDB').and.returnValue db
      LocalDB.init()

    it 'should initilize the database', ->
      expect(LocalDB.pouchDB).toHaveBeenCalledWith 'localStorage',
        location: 2
        androidDatabaseImplementation: 2
        adapter: 'websql'

    it 'should set the db on the service', ->
      expect(LocalDB.db).toBe db

  describe 'saving to the database', ->
    someValue = null
    someKey = null
    db = null
    promise = null

    beforeEach (done) ->
      db = new window.PouchDB 'localStorage'
      LocalDB.db = db

      someKey = 'someKey'
      someValue =
        id: 1
        name: 'Some name'

      promise = LocalDB.set(someKey, someValue)
      console.log promise
      promise.then ->
        console.log 'resolved'
        done()
      , ->
        console.log 'rejected'
        done()

      # $rootScope.$apply()
      $timeout.flush()


    afterEach ->
      db.destroy()

    it 'should save the item in the database', (done) ->
      console.log promise
      console.log 'here'
      key = "_local/#{someKey}"
      db.get(key).then (doc) ->
        console.log doc
        expect(doc).toEqual someValue
        done()
      , (err) ->
        console.log err
        done()


