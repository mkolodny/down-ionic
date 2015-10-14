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
    query = "SELECT * FROM local_storage WHERE key=#{key} LIMIT 1"
    @$cordovaSQLite.execute @db, query
    
  set: (key, value) ->
    value = JSON.stringify value
    query = "INSERT OR REPLACE INTO local_storage (key, value) VALUES (#{key}, #{value})"
    @$cordovaSQLite.execute @db, query
    

module.exports = LocalDB
