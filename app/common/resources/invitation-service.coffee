Invitation = ($resource, apiRoot, Event, User) ->
  listUrl = "#{apiRoot}/invitations"
  serializeInvitation = (invitation) ->
    invitation =
      id: invitation.id
      event: invitation.eventId
      to_user: invitation.toUserId
      from_user: invitation.fromUserId
      response: invitation.response
      previously_accepted: invitation.previouslyAccepted
      open: invitation.open
      to_user_messaged: invitation.toUserMessaged
      muted: invitation.muted
      created_at: invitation.createdAt.getTime()
      updated_at: invitation.updatedAt.getTime()
    invitation
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

    # Always set a `relationId` attribute on the invitation. If the response
    # relation is an object, also set the relation on the invitation.
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
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request = serializeInvitation data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeInvitation data

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

  resource.serialize = serializeInvitation

  resource.deserialize = deserializeInvitation

  resource.noResponse = 0

  resource.accepted = 1

  resource.declined = 2

  resource.maybe = 3

  resource

module.exports = Invitation
