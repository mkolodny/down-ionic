SavedEvent = ['$resource', 'apiRoot', 'Event', 'User', \
              ($resource, apiRoot, Event, User) ->
  listUrl = "#{apiRoot}/saved-events"
  
  serializeSavedEvent = (savedEvent) ->
    request =
      user: savedEvent.userId
      event: savedEvent.eventId

    optionalFields =
      id: 'id'

    for serializedField, deserializedField of optionalFields
      if savedEvent[deserializedField]?
        request[serializedField] = savedEvent[deserializedField]

    request

  deserializeSavedEvent = (response) ->
    savedEvent =
      id: response.id

    # Always set a `<relation>Id` attribute on the savedEvent. If the relation is
    # an object, also set the relation on the savedEvent.
    if angular.isNumber response.event
      savedEvent.eventId = response.event
    else
      savedEvent.event = Event.deserialize response.event
      savedEvent.eventId = savedEvent.event.id

    if angular.isNumber response.user
      savedEvent.userId = response.user
    else
      savedEvent.user = User.deserialize response.user
      savedEvent.userId = savedEvent.user.id

    savedEvent

  resource = $resource '#{listUrl}/:id', null,
    query: {}

  resource.listUrl = listUrl

  resource.serialize = serializeSavedEvent
  resource.deserialize = deserializeSavedEvent

  resource
]

module.exports = SavedEvent
