Event = ($http, $q, $resource, apiRoot, Auth, Invitation, User) ->
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
    if event.members?
      response.members = (new Invitation(Invitation.deserialize(invitation)) \
          for invitation in event.members)
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

    sendMessage:
      method: 'post'
      url: "#{detailUrl}/messages"
      params: {id: '@eventId'}
      transformRequest: (data, headersGetter) ->
        delete data.eventId
        angular.toJson data

    cancel:
      method: 'delete'
      url: detailUrl

  resource.serialize = serializeEvent

  resource.deserialize = deserializeEvent

  resource.getInvitedEvents = ->
    deferred = $q.defer()

    $http.get "#{User.listUrl}/#{Auth.user.id}/invited_events"
      .success (data, status) ->
        events = (new resource(deserializeEvent(event)) for event in data)

        # Create an array of unique user ids of users participating in the
        # returned events.
        userIds = {}
        for event in events
          userIds[event.creatorId] = true
          for member in event.members
            userIds[member.fromUserId] = true
            userIds[member.toUserId] = true

        # Fetch the users participating in the returned events.
        ids = (id for id, bool of userIds).join ','
        query = User.query {ids: ids}
          .$promise.then (response) ->
            # Map each user id to the user object.
            usersDict = {}
            for user in response
              usersDict[user.id] = new User(user)

            for event in events
              event.creator = usersDict[event.creatorId]

              for member in event.members
                member.fromUser = usersDict[member.fromUserId]
                member.toUser = usersDict[member.toUserId]

            deferred.resolve events
          , ->
            deferred.reject()
      .error (data, status) ->
        deferred.reject()

    deferred.promise

  resource

module.exports = Event
