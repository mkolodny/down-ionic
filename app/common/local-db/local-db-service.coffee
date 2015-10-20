class LocalDB
  @$inject: ['$cordovaSQLite', '$q', '$window', 'localStorageService']
  constructor: (@$cordovaSQLite, @$q, @$window, localStorageService) ->
    @localStorage = localStorageService

  init: ->
    deferred = @$q.defer()

    # Convert localStorage to use the new data
    #   format (session, contacts)
    @convertLocalStorage()

    sqlitePluginInstalled = angular.isDefined @$window.sqlitePlugin
    isApp = @$window.ionic.Platform.isIOS() or @$window.ionic.Platform.isAndroid()
    if sqlitePluginInstalled or !isApp
      # Open DB connection
      @db = @$cordovaSQLite.openDB
        name: 'rallytap.db'
        location: 2
      # Create local_storage table if needed
      query = 'CREATE TABLE IF NOT EXISTS local_storage (key string primary key, value text)'
      @$cordovaSQLite.execute @db, query
        .then =>
          if @localStorage.get('session') is null
            # Already converted to SQLite and 
            #   localStorage has been cleared
            deferred.resolve()
          else
            # Convert old local storage to LocalDB
            @convertLocalStorageToSQLite().then =>
              deferred.resolve()
        , ->
          deferred.reject()
    else
      # for backwards compatibility
      deferred.resolve()

    deferred.promise

  get: (key) ->
    deferred = @$q.defer()

    sqlitePluginInstalled = angular.isDefined @$window.sqlitePlugin
    isApp = @$window.ionic.Platform.isIOS() or @$window.ionic.Platform.isAndroid()
    if sqlitePluginInstalled or !isApp
      query = "SELECT * FROM local_storage WHERE key='#{key}' LIMIT 1"
      @$cordovaSQLite.execute @db, query
        .then (sqlResultSet) ->
          if sqlResultSet.rows.length is 0
            # No data found
            deferred.resolve null
          else
            value = sqlResultSet.rows[0]?.value
            deferred.resolve angular.fromJson(value)
        , (error) ->
          deferred.reject()
    else
      # backwards compatibility
      deferred.resolve @localStorage.get key

    deferred.promise
    
  set: (key, value) ->
    sqlitePluginInstalled = angular.isDefined @$window.sqlitePlugin
    isApp = @$window.ionic.Platform.isIOS() or @$window.ionic.Platform.isAndroid()
    if sqlitePluginInstalled or !isApp
      value = angular.toJson value
      query = "INSERT OR REPLACE INTO local_storage (key, value) VALUES ('#{key}', '#{value}')"
      @$cordovaSQLite.execute(@db, query)
    else
      deferred = @$q.defer()
      @localStorage.set key, value
      deferred.resolve()
      deferred.promise

  convertLocalStorage: ->
    # if already converted, do nothing
    if @localStorage.get('session') isnt null then return

    # Get data from localStorage
    currentUser = @localStorage.get 'currentUser'
    currentPhone = @localStorage.get 'currentPhone'
    hasViewedTutorial = @localStorage.get('hasViewedTutorial') is true ? true : undefined
    hasRequestedLocationServices = @localStorage.get('hasRequestedLocationServices') is true ? true : undefined
    hasRequestedPushNotifications = @localStorage.get('hasRequestedPushNotifications') is true ? true : undefined
    hasRequestedContacts = @localStorage.get('hasRequestedContacts') is true ? true : undefined
    hasCompletedFindFriends = @localStorage.get('hasCompletedFindFriends') is true ? true : undefined
    # Switch to session object
    session =
      user: currentUser
      phone: currentPhone
      flags:
        hasViewedTutorial: hasViewedTutorial
        hasRequestedLocationServices: hasRequestedLocationServices
        hasRequestedPushNotifications: hasRequestedPushNotifications
        hasRequestedContacts: hasRequestedContacts
        hasCompletedFindFriends: hasCompletedFindFriends
    @localStorage.set 'session', session

  convertLocalStorageToSQLite: ->
    deferred = @$q.defer()

    session = @localStorage.get 'session'
    @set 'session', session
      .then =>
        @convertContacts()
      .then =>
        @localStorage.clearAll()
        deferred.resolve()

    deferred.promise
      
  convertContacts: ->
    contacts = @localStorage.get 'contacts'
    @set 'contacts', contacts

module.exports = LocalDB
