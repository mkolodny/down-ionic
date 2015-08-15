Event = ($http, $q, $resource, apiRoot, Asteroid, Auth, User) ->
  listUrl = "#{apiRoot}/events"
  detailUrl = "#{listUrl}/:id"
  serializeEvent = (event) ->
    request =
      id: event.id
      creator: event.creatorId
      title: event.title
    if event.datetime?
      request.datetime = event.datetime?.getTime()
    if event.place?
      request.place =
        name: event.place?.name
        geo:
          type: 'Point'
          coordinates: [event.place?.lat, event.place?.long]
    if event.comment?
      request.comment = event.comment
    if event.canceled?
      request.canceled = event.canceled
    if event.invitations?
      request.invitations = event.invitations
    request
  deserializeEvent = (event) ->
    response =
      id: event.id
      creatorId: event.creator
      title: event.title
      datetime: new Date(event.datetime)
      place:
        name: event.place?.name
        lat: event.place?.geo.coordinates[0]
        long: event.place?.geo.coordinates[1]
      comment: event.comment
      canceled: event.canceled
      createdAt: new Date(event.created_at)
      updatedAt: new Date(event.updated_at)
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

    # Save the message on the django server.
    url = "#{listUrl}/#{event.id}/messages"
    requestData = {text: text}
    $http.post url, requestData

  resource

module.exports = Event
