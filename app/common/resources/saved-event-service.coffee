SavedEvent = ['$resource', 'apiRoot', ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/saved-events"
  
  serializeSavedEvent = (savedEvent) ->

  deserializeSavedEvent = (data) ->


  resource = $resource '#{listUrl}/:id', null,
    save: {}

  resource.listUrl = listUrl

  resource.serialize = serializeSavedEvent
  resource.deserialize = deserializeSavedEvent

  resource
]

module.exports = SavedEvent
