Invitation = ($http, $q, $resource, apiRoot, Asteroid, Auth, Event, User) ->
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
      previously_accepted: 'previouslyAccepted'
      to_user_messaged: 'toUserMessaged'
      muted: 'muted'
    for serializedField, deserializedField of optionalFields
      if invitation[deserializedField]?
        request[serializedField] = invitation[deserializedField]
    if invitation.lastViewed?
      request.last_viewed = invitation.lastViewed.toISOString()
    request
  deserializeInvitation = (response) ->
    invitation =
      id: response.id
      response: response.response
      previouslyAccepted: response.previously_accepted
      toUserMessaged: response.to_user_messaged
      muted: response.muted
      createdAt: new Date(response.created_at)
      updatedAt: new Date(response.updated_at)
      lastViewed: new Date(response.last_viewed)

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
    bulkCreate:
      method: 'post'
      isArray: true
      transformRequest: (data, headersGetter) ->
        invitations = (serializeInvitation(invitation) for invitation in data)
        request = invitations: invitations
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        (deserializeInvitation(invitation) for invitation in data)

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

    getEventInvitations:
      method: 'get'
      url: "#{Event.listUrl}/:id/invitations"
      params:
        id: '@id'
      isArray: true
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        (deserializeInvitation(invitation) for invitation in data)

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
      # Post an action message.
      if _invitation.response is @accepted
        text = "#{Auth.user.name} is down"
        type = @acceptAction
      else if _invitation.response is @maybe
        text = "#{Auth.user.name} might be down"
        type = @maybeAction
      else if _invitation.response is @declined
        text = "#{Auth.user.name} can't make it"
        type = @declineAction
      Messages = Asteroid.getCollection 'messages'
      Messages.insert
        creator:
          id: Auth.user.id
          name: Auth.user.name
          firstName: Auth.user.firstName
          lastName: Auth.user.lastName
          imageUrl: Auth.user.imageUrl
        text: text
        eventId: _invitation.eventId
        type: type
        createdAt:
          $date: new Date().getTime()
    , ->
      invitation.response = originalResponse
      deferred.reject()

    {$promise: deferred.promise}

  resource

module.exports = Invitation
