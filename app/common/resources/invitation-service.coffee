Invitation = ['$http', '$meteor', '$mixpanel', '$q', '$resource', \
              'apiRoot', 'Auth', 'Event', 'Friendship', 'User', \
              ($http, $meteor, $mixpanel, $q, $resource,
               apiRoot, Auth, Event, Friendship, User) ->
  listUrl = "#{apiRoot}/invitations"
  detailUrl =
  serializeInvitation = (invitation) ->
    request =
      to_user: invitation.toUserId
    optionalFields =
      id: 'id'
      event: 'eventId'
      from_user: 'fromUserId'
      response: 'response'
      muted: 'muted'
    for serializedField, deserializedField of optionalFields
      if invitation[deserializedField]?
        request[serializedField] = invitation[deserializedField]
    request
  deserializeInvitation = (response) ->
    invitation =
      id: response.id
      response: response.response
      muted: response.muted
      createdAt: new Date response.created_at
      updatedAt: new Date response.updated_at

    # Always set a `<relation>Id` attribute on the invitation. If the relation is
    # an object, also set the relation on the invitation.
    if angular.isNumber response.event
      invitation.eventId = response.event
    else
      invitation.event = Event.deserialize response.event
      invitation.eventId = invitation.event.id

    if angular.isNumber response.from_user
      invitation.fromUserId = response.from_user
    else
      invitation.fromUser = User.deserialize response.from_user
      invitation.fromUserId = invitation.fromUser.id

    if angular.isNumber response.to_user
      invitation.toUserId = response.to_user
    else
      invitation.toUser = User.deserialize response.to_user
      invitation.toUserId = invitation.toUser.id

    invitation

  resource = $resource "#{listUrl}/:id", null,
    update:
      method: 'put'
      params:
        id: '@id'
      transformRequest: (data, headersGetter) ->
        request = serializeInvitation data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeInvitation data

    query:
      method: 'get'
      isArray: true
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        (deserializeInvitation(invitation) for invitation in data)

    ###
    Get an array of invitations with responses.
    ###
    getMemberInvitations:
      method: 'get'
      url: "#{Event.listUrl}/:id/member-invitations"
      params:
        id: '@id'
      isArray: true
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        (deserializeInvitation(invitation) for invitation in data)

  # URLs
  resource.listUrl = listUrl

  # Tranform data to/from the server.
  resource.serialize = serializeInvitation
  resource.deserialize = deserializeInvitation

  # Invitation response enum values
  resource.noResponse = 0
  resource.accepted = 1
  resource.declined = 2
  resource.maybe = 3

  # Action message enum values
  resource.acceptAction = 'accept_action'
  resource.declineAction = 'decline_action'
  resource.maybeAction = 'maybe_action'
  resource.inviteAction = 'invite_action'
  resource.errorAction = 'error_action'
  resource.textMessage = 'text'

  resource.bulkCreate = (eventId, invitations) ->
    deferred = $q.defer()

    invitationsPostData = (@serialize invitation \
      for invitation in invitations)

    postData =
      event: eventId
      invitations: invitationsPostData

    $http.post listUrl, postData
      .success (data, status) =>
        invitations = (@deserialize invitation for invitation in data)

        # Create invite_action messages
        Messages = $meteor.getCollectionByName 'messages'
        for invitation in invitations
          Messages.insert
            creator:
              id: "#{Auth.user.id}" # Meteor likes strings
              name: Auth.user.name
              firstName: Auth.user.firstName
              lastName: Auth.user.lastName
              imageUrl: Auth.user.imageUrl
            text: "#{Auth.user.firstName}: Down?"
            chatId: Friendship.getChatId invitation.toUserId
            type: @inviteAction
            createdAt: new Date()
            meta:
              eventId: "#{invitation.eventId}"
          , @readMessage

        deferred.resolve invitations
      .error (data, status) =>
        deferred.reject()

    deferred.promise

  resource.getMyInvitations = ->
    deferred = $q.defer()

    $http.get "#{User.listUrl}/invitations"
      .success (data, status) =>
        invitations = (deserializeInvitation invitation for invitation in data)
        deferred.resolve invitations
      .error (data, status) =>
        deferred.reject()

    deferred.promise

  resource.updateResponse = (invitation, newResponse) ->
    deferred = $q.defer()

    originalResponse = invitation.response
    invitation.response = newResponse
    @update(invitation).$promise.then (_invitation) =>
      # Re-subscribe to event messages
      $meteor.subscribe 'chat', "#{_invitation.eventId}" # Meteor likes strings

      # Post an action message.
      if _invitation.response is @accepted
        text = "#{Auth.user.name} is down."
        type = @acceptAction
        status = 'accepted'
      else if _invitation.response is @maybe
        text = "#{Auth.user.name} joined the chat."
        type = @maybeAction
        status = 'maybe'
      else if _invitation.response is @declined
        text = "#{Auth.user.name} can't make it."
        type = @declineAction
        status = 'declined'
      $mixpanel.track 'Update Response', {status: status}
      Messages = $meteor.getCollectionByName 'messages'
      Messages.insert
        creator:
          id: "#{Auth.user.id}" # Meteor likes strings
          name: Auth.user.name
          firstName: Auth.user.firstName
          lastName: Auth.user.lastName
          imageUrl: Auth.user.imageUrl
        text: text
        chatId: "#{_invitation.eventId}" # Meteor likes strings
        type: type
        createdAt: new Date()
      , @readMessage

      deferred.resolve invitation
    , ->
      invitation.response = originalResponse
      deferred.reject()

    {$promise: deferred.promise}

  resource.getUserInvitations = (userId) ->
    @query {user: userId}

  resource.readMessage = (error, messageId) ->
    $meteor.call 'readMessage', messageId

  resource
]

module.exports = Invitation
