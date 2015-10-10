class LocalDB
  @$inject: ['$q', '$rootScope', '$window']
  constructor: (@$q, @$rootScope, @$window) ->
   


  init: ->
    # Options docs: http://pouchdb.com/api.html
    @db = new @$window.PouchDB 'localStorage',
      location: 2 # Not visible in iTunes, not backed up to iCloud
      androidDatabaseImplementation: 2 # Use native SQLite
      adapter: 'websql' # For SQLite plugin
    
    # Get localStorage document
    deferred = @$q.defer()

    @key = '_local/localStorage'
    @db.get(@key).catch (err) =>
      if err.status is 404
        # Default to blank object
        return {_id: @key}
      else
        throw err
    .then (doc) =>
      @data = doc
      deferred.resolve @data
    , (err) =>
      deferred.reject()

    deferred.promise

  get: (key) ->
    @data[key]

  set: (key, value) ->
    @data[key] = value
    @db.put(@data).then (response) =>
      # Update LocalDB.data._rev for future updates
      @data._rev = response.rev

module.exports = LocalDB
