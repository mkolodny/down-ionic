class LocalDB
  @$inject: ['$cordovaSQLite', '$q']
  constructor: (@$cordovaSQLite, @$q) ->
   
  init: ->
    deferred = @$q.defer()

    # Open DB connection
    @db = @$cordovaSQLite.openDB
      name: 'rallytap.db'
      location: 2
    # Create local_storage table if needed
    query = 'CREATE TABLE IF NOT EXISTS local_storage (key string primary key, value text)'
    @$cordovaSQLite.execute @db, query
      .then =>
        deferred.resolve()
      , ->
        deferred.reject()

    deferred.promise

  get: (key) ->
    deferred = @$q.defer()

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

    deferred.promise
    
  set: (key, value) ->
    value = angular.toJson value
    query = "INSERT OR REPLACE INTO local_storage (key, value) VALUES ('#{key}', '#{value}')"
    @$cordovaSQLite.execute(@db, query)
    

module.exports = LocalDB
