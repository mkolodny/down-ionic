LinkInvitation = ($resource, apiRoot, Event, User) ->
  listUrl = "#{apiRoot}/link-invitations"

  serializeLinkInvitation = (linkInvitation) ->
    data =
      event: linkInvitation.eventId
      from_user_id: linkInvitation.fromUserId
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
        deserializeLinkInvitation data

  resource.serialize = serializeLinkInvitation
  resource.deserialize = deserializeLinkInvitation

  resource

module.exports = LinkInvitation
