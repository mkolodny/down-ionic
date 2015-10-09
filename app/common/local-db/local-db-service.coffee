class LocalDB
  @$inject: ['$q', '$rootScope', '$window']
  constructor: (@$q, @$rootScope, @$window) ->
   
  init: ->
    # Options docs: http://pouchdb.com/api.html
    @db = pouchDB 'localStorage',
      location: 2 # Not visible in iTunes, not backed up to iCloud
      androidDatabaseImplementation: 2 # Use native SQLite
      adapter: 'websql' # For SQLite plugin

  get: (key) ->
    deferred = @$q.defer()

    key = "_local/#{key}"
    @db.get(key).then (doc) =>
      deferred.resolve doc
    , (err) =>
      deferred.reject()

    deferred.promise

  set: (key, value) ->
    key = "_local/#{key}"
    @db.get(key).then (doc) =>
      angular.extend doc, value
      @db.put doc
    , (err) =>
      # No dock exists, put
      @db.put key, value


module.exports = LocalDB
