require '../../ionic/ionic.js'
require 'angular'
require 'angular-mocks'
require 'angular-local-storage'
require '../ng-cordova/sqlite.js'
require './local-db-module'

describe 'LocalDB service', ->
  $cordovaSQLite = null
  $rootScope = null
  $q = null
  $window = null
  LocalDB = null
  localStorage = null

  beforeEach angular.mock.module('down.localDB')

  beforeEach angular.mock.module('ngCordova.plugins.sqlite')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach inject(($injector) ->
    $cordovaSQLite = $injector.get '$cordovaSQLite'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $window = $injector.get '$window'
    LocalDB = $injector.get 'LocalDB'
    localStorage = $injector.get 'localStorageService'
  )

  describe 'initilizing the database', ->
    resolved = null
    rejected = null

    describe 'when the plugin exists', ->
      db = null
      deferred = null

      beforeEach ->
        $window.sqlitePlugin = {}
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

        describe 'when no localStorage data is found', ->
          
          beforeEach ->
            deferred.resolve()
            $rootScope.$apply()

          it 'should resolve the promise', ->
            expect(resolved).toBe true

        describe 'when converting old localStorage data', ->
          convertDeferred = null

          beforeEach ->
            localStorage.set 'currentUser', {}
            convertDeferred = $q.defer()
            spyOn(LocalDB, 'convertLocalStorage') \
              .and.returnValue convertDeferred.promise

            deferred.resolve()
            $rootScope.$apply()

          it 'should convert the data', ->
            expect(LocalDB.convertLocalStorage).toHaveBeenCalled()

          describe 'when conversion is complete', ->

            beforeEach ->
              convertDeferred.resolve()
              $rootScope.$apply()

            it 'should resolve the promise', ->
              expect(resolved).toBe true


      describe 'on error', ->

        beforeEach ->
          deferred.reject()
          $rootScope.$apply()

        it 'should reject the promise', ->
          expect(rejected).toBe true


    describe 'supporting backwards compatibility with localStorage', ->

      beforeEach ->
        delete $window.sqlitePlugin

        LocalDB.init().then ->
          resolved = true
        $rootScope.$apply()

      it 'should resolve the promise', ->
        expect(resolved).toBe true


  describe 'getting a value', ->

    describe 'when the sqlite plugin is installed', ->

      deferred = null
      key = null
      result = null
      rejected = null

      beforeEach ->
        $window.sqlitePlugin = {} # mock plugin being installed
        deferred = $q.defer()
        spyOn($cordovaSQLite, 'execute').and.returnValue deferred.promise
        key = 'someKey'
        LocalDB.get(key).then (_result_) ->
          result = _result_
        , ->
          rejected = true

      it 'should query local_storage by key', ->
        query = "SELECT * FROM local_storage WHERE key='#{key}' LIMIT 1"
        expect($cordovaSQLite.execute).toHaveBeenCalledWith LocalDB.db, query

      describe 'when the query executes successfully', ->

        describe 'when data is found', ->
          value = null

          beforeEach ->
            value = 
              id: 2
              name: 'Jimbo Walker'

            sqlResultSet =
              rows: [
                key: key
                value: angular.toJson angular.copy(value)
              ]

            deferred.resolve sqlResultSet
            $rootScope.$apply()

          it 'should resolve the promise with the JSON value', ->
            expect(result).toEqual value

        describe 'when no data is found', ->

          beforeEach ->
            sqlResultSet =
              rows: []

            deferred.resolve sqlResultSet
            $rootScope.$apply()

          it 'should return null', ->
            expect(result).toBeNull()


      describe 'when the query fails', ->

        beforeEach ->
          deferred.reject()
          $rootScope.$apply()

        it 'should reject the promise', ->
          expect(rejected).toBe true


    describe 'supporting backwards compatibility', ->
      someKey = null
      someValue = null
      result = null

      beforeEach ->
        delete $window.sqlitePlugin
        someKey = 'someKey'
        someValue = 'someValue'
        localStorage.set someKey, someValue
        LocalDB.get(someKey).then (_result_) ->
          result = _result_
        $rootScope.$apply()

      it 'should resolve the promise with the value from localstorage', ->
        expect(result).toEqual someValue


  describe 'setting a value', ->
    key = null
    value = null

    beforeEach ->
      key = 'someKey'
      value =
        id: 1
        name: 'Mike Pleb'
        friends: 'none'

    describe 'when the plugin is installed', ->
      promise = null
      result = null

      beforeEach ->
        $window.sqlitePlugin = {}
        promise = 'promise'
        spyOn($cordovaSQLite, 'execute').and.returnValue promise

        result = LocalDB.set key, value

      it 'should query local_storage by key', ->
        value = angular.toJson value
        query = "INSERT OR REPLACE INTO local_storage (key, value) VALUES ('#{key}', '#{value}')"
        expect($cordovaSQLite.execute).toHaveBeenCalledWith LocalDB.db, query

      it 'should return the $cordovaSQLite.execute promise', ->
        expect(result).toBe promise


    describe 'supporting backwards compatibility', ->
      resolved = null

      beforeEach ->
        delete $window.sqlitePlugin
        LocalDB.set(key, value).then ->
          resolved = true
        $rootScope.$apply()

      it 'should set the value in localStorage', ->
        expect(localStorage.get(key)).toEqual value

      it 'should resolve the promise', ->
        expect(resolved).toBe true


  ##convertLocalStorage
  describe 'converting localStorage data to SQLite', ->
    resolved = null
    rejected = null
    currentUser = null
    currentPhone = null
    deferred = null

    beforeEach ->
      # Mock localStorage data
      currentUser =
        id: 1
        name: 'Jimbo Walker'
      currentPhone = '+19252852230'
      localStorage.set 'currentUser', currentUser
      localStorage.set 'currentPhone', currentPhone
      localStorage.set 'hasViewedTutorial', true
      localStorage.set 'hasRequestedLocationServices', true
      localStorage.set 'hasRequestedPushNotifications', true
      localStorage.set 'hasRequestedContacts', true
      localStorage.set 'hasCompletedFindFriends', true

      deferred = $q.defer()
      spyOn(LocalDB, 'set').and.returnValue deferred.promise

      LocalDB.convertLocalStorage().then ->
        resolved = true

    it 'should save the session object', ->
      expect(LocalDB.set).toHaveBeenCalledWith 'session',
        user: currentUser
        phone: currentPhone
        flags:
          hasViewedTutorial: true
          hasRequestedLocationServices: true
          hasRequestedPushNotifications: true
          hasRequestedContacts: true
          hasCompletedFindFriends: true

    describe 'when saved successfully', ->
      convertContactsDeferred = null

      beforeEach ->
        convertContactsDeferred = $q.defer()
        spyOn(LocalDB, 'convertContacts') \
        .and.returnValue convertContactsDeferred

        deferred.resolve()
        $rootScope.$apply()

      it 'should convert contacts', ->
        expect(LocalDB.convertContacts).toHaveBeenCalled()

      describe 'when successful', ->

        beforeEach ->
          spyOn localStorage, 'clearAll'
          convertContactsDeferred.resolve()
          $rootScope.$apply()

        it 'should clear localstorage', ->
          expect(localStorage.get('currentUser')).toBeNull()

        it 'should resolve the promise', ->
          expect(resolved).toBe true


  ##convertContacts
  describe 'converting contacts from localstorage', ->
    promise = null
    result = null
    contacts = null

    beforeEach ->
      promise = 'promise'
      contacts =
        2:
          someKey: 'someValue'
      localStorage.set 'contacts', contacts

      spyOn(LocalDB, 'set').and.returnValue promise
      result = LocalDB.convertContacts()

    it 'should save contacts to LocalDB', ->
      expect(LocalDB.set).toHaveBeenCalledWith 'contacts', contacts

    it 'should return the LocalDB.set promise', ->
      expect(result).toEqual promise

