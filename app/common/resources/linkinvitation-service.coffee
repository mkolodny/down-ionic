LinkInvitation = ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/link-invitations"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          event_id: data.eventId
          from_user_id: data.fromUserId
          link_id: data.linkId
          created_at: data.createdAt.getTime()
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          eventId: data.event_id
          fromUserId: data.from_user_id
          linkId: data.link_id
          createdAt: new Date(data.created_at)
        response

module.exports = LinkInvitation
