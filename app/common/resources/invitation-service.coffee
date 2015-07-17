Invitation = ($resource, apiRoot) ->
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
  deserializeInvitation = (invitation) ->
    invitation =
      id: invitation.id
      eventId: invitation.event
      toUserId: invitation.to_user
      fromUserId: invitation.from_user
      response: invitation.response
      previouslyAccepted: invitation.previously_accepted
      open: invitation.open
      toUserMessaged: invitation.to_user_messaged
      muted: invitation.muted
      createdAt: new Date(invitation.created_at)
      updatedAt: new Date(invitation.updated_at)
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

  resource

module.exports = Invitation
