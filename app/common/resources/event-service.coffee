Event = ['$http', '$meteor', '$q', '$resource', 'apiRoot', 'Auth', 'Friendship', 'User', \
         ($http, $meteor, $q, $resource, apiRoot, Auth, Friendship, User) ->
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
    eventCopy = angular.copy event

    data = serializeEvent event

    # needed to create invite action messages because
    #   DJANGO! server doesn't return the invitations
    $http.post listUrl, data
      .success (data, status) =>
        event = deserializeEvent data

        # Create the first action message.
        Messages = $meteor.getCollectionByName 'messages'
        Messages.insert
          creator:
            id: "#{Auth.user.id}" # Meteor likes strings
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: "#{Auth.user.name} is down."
          chatId: "#{event.id}" # Meteor likes strings
          type: 'accept_action' # We can't use Invitation.acceptAction because it
                                #   would create a circular dependecy.
          createdAt: new Date()
        , @readMessage

        # Create invite_action messages
        for invitation in eventCopy.invitations
          toUser = invitation.to_user # they are serialized for the server
          if toUser is Auth.user.id then continue

          Messages.insert
            creator:
              id: "#{Auth.user.id}" # Meteor likes strings
              name: Auth.user.name
              firstName: Auth.user.firstName
              lastName: Auth.user.lastName
              imageUrl: Auth.user.imageUrl
            text: "#{Auth.user.firstName}: Down?"
            chatId: Friendship.getChatId toUser # Meteor likes strings
            type: 'invite_action' # We can't use Invitation.invite_action because it
                                  #   would create a circular dependecy.
            createdAt: new Date()
            meta:
              eventId: "#{event.id}"

        deferred.resolve event
      .error (data, status) =>
        deferred.reject()

    {$promise: deferred.promise}

  resource.readMessage = (messageId) ->
    $meteor.call 'readMessage', messageId

  resource.sendMessage = (event, text) ->
    # Save the message on the meteor server.
    Messages = $meteor.getCollectionByName 'messages'
    Messages.insert
      creator:
        id: "#{Auth.user.id}" # Meteor likes strings
        name: Auth.user.name
        firstName: Auth.user.firstName
        lastName: Auth.user.lastName
        imageUrl: Auth.user.imageUrl
      text: text
      chatId: "#{event.id}" # Meteor likes strings
      type: 'text'
      createdAt: new Date()

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
