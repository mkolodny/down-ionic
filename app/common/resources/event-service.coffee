Event = ['$http', '$q', '$resource', 'apiRoot', 'Asteroid', 'Auth', 'User', \
         ($http, $q, $resource, apiRoot, Asteroid, Auth, User) ->
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
      createdAt: new Date event.created_at
      updatedAt: new Date event.updated_at
    if event.datetime?
      response.datetime = new Date event.datetime
    if event.place?
      response.place =
        name: event.place.name
        lat: event.place.geo.coordinates[0]
        long: event.place.geo.coordinates[1]
    if event.comment?
      response.comment = event.comment
    new resource response

  resource = $resource detailUrl, null,
    cancel:
      method: 'delete'
      url: detailUrl

  resource.listUrl = listUrl

  resource.serialize = serializeEvent
  resource.deserialize = deserializeEvent

  resource.save = (event) ->
    deferred = $q.defer()

    data = serializeEvent event
    $http.post listUrl, data
      .success (data, status) =>
        event = deserializeEvent data

        # Create the first action message.
        Messages = Asteroid.getCollection 'messages'
        Messages.insert
          creator:
            id: "#{Auth.user.id}" # Meteor likes strings
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: "#{Auth.user.name} might be down."
          eventId: "#{event.id}" # Meteor likes strings
          type: 'maybe_action' # We can't use Invitation.maybeAction because it
                               #   would create a circular dependecy.
          createdAt:
            $date: new Date().getTime()
        .remote.then (messageId) ->
          Asteroid.call 'readMessage', messageId

        deferred.resolve event
      .error (data, status) =>
        deferred.reject()

    {$promise: deferred.promise}

  resource.sendMessage = (event, text) ->
    # Save the message on the meteor server.
    Messages = Asteroid.getCollection 'messages'
    Messages.insert
      creator:
        id: "#{Auth.user.id}" # Meteor likes strings
        name: Auth.user.name
        firstName: Auth.user.firstName
        lastName: Auth.user.lastName
        imageUrl: Auth.user.imageUrl
      text: text
      eventId: "#{event.id}" # Meteor likes strings
      type: 'text'
      createdAt:
        $date: new Date().getTime()

    # Save the message on the django server.
    url = "#{listUrl}/#{event.id}/messages"
    requestData = {text: text}
    $http.post url, requestData

  resource::getPercentRemaining = ->
    currentDate = new Date()
    twentyFourHrsAgo = angular.copy currentDate
    twentyFourHrsAgo.setDate currentDate.getDate()-1
    oneDay = currentDate - twentyFourHrsAgo

    if @datetime?
      oneDayAfterEvent = @datetime.getTime() + oneDay
      eventDuration = oneDayAfterEvent - @createdAt.getTime()
      timeRemaining = oneDayAfterEvent - currentDate.getTime()
    else
      eventDuration = oneDay
      timeRemaining = @createdAt - twentyFourHrsAgo

    (timeRemaining / eventDuration) * 100

  resource.getInvitedIds = (event) ->
    deferred = $q.defer()

    $http.get "#{listUrl}/#{event.id}/invited-ids"
      .success (data, status) ->
        deferred.resolve data
      .error (data, status) ->
        deferred.reject()

    deferred.promise

  resource
]

module.exports = Event
