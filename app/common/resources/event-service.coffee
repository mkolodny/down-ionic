Event = ($http, $q, $resource, apiRoot, Asteroid, Auth, User) ->
  listUrl = "#{apiRoot}/events"
  detailUrl = "#{listUrl}/:id"
  serializeEvent = (event) ->
    request =
      creator: event.creatorId
      title: event.title
    optionalFields =
      id: 'id'
      comment: 'comment'
      canceled: 'canceled'
      invitations: 'invitations'
    for serializedField, deserializedField of optionalFields
      if event[deserializedField]?
        request[serializedField] = event[deserializedField]
    if event.place?
      request.place =
        name: event.place?.name
        geo:
          type: 'Point'
          coordinates: [event.place?.lat, event.place?.long]
    if event.datetime?
      request.datetime = event.datetime.toISOString()
    request
  deserializeEvent = (event) ->
    response =
      id: event.id
      creatorId: event.creator
      title: event.title
      canceled: event.canceled
      createdAt: new Date(event.created_at)
      updatedAt: new Date(event.updated_at)
    if event.datetime?
      response.datetime = new Date(event.datetime)
    if event.place?
      response.place =
        name: event.place.name
        lat: event.place.geo.coordinates[0]
        long: event.place.geo.coordinates[1]
    if event.comment?
      response.comment = event.comment
    response

  resource = $resource "#{detailUrl}", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request = serializeEvent data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeEvent data

    cancel:
      method: 'delete'
      url: detailUrl

  resource.listUrl = listUrl

  resource.serialize = serializeEvent

  resource.deserialize = deserializeEvent

  resource.sendMessage = (event, text) ->
    # Save the message on the meteor server.
    Messages = Asteroid.getCollection 'messages'
    Messages.insert
      creator:
        id: Auth.user.id
        name: Auth.user.name
        imageUrl: Auth.user.imageUrl
      text: text
      eventId: event.id
      type: 'text'
      createdAt:
        $date: new Date().getTime()

    # Save the message on the django server.
    url = "#{listUrl}/#{event.id}/messages"
    requestData = {text: text}
    $http.post url, requestData

  resource

module.exports = Event
