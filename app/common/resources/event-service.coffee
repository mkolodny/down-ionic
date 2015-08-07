Event = ($http, $q, $resource, apiRoot, Asteroid, Auth, User) ->
  listUrl = "#{apiRoot}/events"
  detailUrl = "#{listUrl}/:id"
  serializeEvent = (event) ->
    request =
      id: event.id
      title: event.title
      creator: event.creatorId
      canceled: event.canceled
      datetime: event.datetime?.getTime()
      created_at: event.createdAt?.getTime()
      updated_at: event.updatedAt?.getTime()
      place:
        name: event.place?.name
        geo:
          type: 'Point'
          coordinates: [event.place?.lat, event.place?.long]
    request
  deserializeEvent = (event) ->
    response =
      id: event.id
      title: event.title
      creatorId: event.creator
      canceled: event.canceled
      datetime: new Date(event.datetime)
      createdAt: new Date(event.created_at)
      updatedAt: new Date(event.updated_at)
      place:
        name: event.place?.name
        lat: event.place?.geo.coordinates[0]
        long: event.place?.geo.coordinates[1]
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
