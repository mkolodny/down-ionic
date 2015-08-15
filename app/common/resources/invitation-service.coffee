Invitation = ($http, $q, $resource, apiRoot, Event, User) ->
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
      open: 'open'
      to_user_messaged: 'toUserMessaged'
      muted: 'muted'
    for serializedField, deserializedField of optionalFields
      if invitation[deserializedField]?
        request[serializedField] = invitation[deserializedField]
    if invitation.lastViewed?
      request.last_viewed = invitation.lastViewed.getTime()
    request
  deserializeInvitation = (response) ->
    invitation =
      id: response.id
      response: response.response
      previouslyAccepted: response.previously_accepted
      open: response.open
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

  resource.noResponse = 0

  resource.accepted = 1

  resource.declined = 2

  resource.maybe = 3

  resource.getMyInvitations = ->
    deferred = $q.defer()

    $http.get "#{User.listUrl}/invitations"
      .success (data, status) =>
        invitations = (deserializeInvitation invitation for invitation in data)
        deferred.resolve invitations
      .error (data, status) =>
        deferred.reject()

    deferred.promise

  resource

module.exports = Invitation
