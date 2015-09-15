LinkInvitation = ['$resource', 'apiRoot', 'Event', 'Invitation', 'User', \
                  ($resource, apiRoot, Event, Invitation, User) ->
  listUrl = "#{apiRoot}/link-invitations"

  serializeLinkInvitation = (linkInvitation) ->
    data =
      event: linkInvitation.eventId
      from_user: linkInvitation.fromUserId
    data
  deserializeLinkInvitation = (response) ->
    linkInvitation =
      linkId: response.link_id
      createdAt: new Date response.created_at
    if angular.isNumber response.event
      linkInvitation.eventId = response.event
    else
      linkInvitation.eventId = response.event.id
      linkInvitation.event = Event.deserialize response.event
    if angular.isNumber response.from_user
      linkInvitation.fromUserId = response.from_user
    else
      linkInvitation.fromUserId = response.from_user.id
      linkInvitation.fromUser = User.deserialize response.from_user
    if angular.isObject response.invitation
      linkInvitation.invitationId = response.invitationId
      linkInvitation.invitation = Invitation.deserialize response.invitation
    linkInvitation

  resource = $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request = serializeLinkInvitation data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeLinkInvitation data

    getByLinkId:
      method: 'get'
      url: "#{listUrl}/:linkId"
      params:
        linkId: '@linkId'
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        if angular.isDefined data.detail # There was an error.
          return null
        deserializeLinkInvitation data

  resource.serialize = serializeLinkInvitation
  resource.deserialize = deserializeLinkInvitation

  resource
]

module.exports = LinkInvitation
