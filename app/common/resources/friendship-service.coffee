Friendship = ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/friendships"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          user: data.userId
          friend: data.friendId
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          userId: data.user
          friendId: data.friend
        response

    ###
    TODO: The request data is being sent as query parameters.
    See: http://stackoverflow.com/questions/22186671/angular-resource-delete-wont-send-body-to-express-js-server
    and http://stackoverflow.com/questions/18924217/how-to-set-custom-headers-with-a-resource-action
    A backup option is to make a PUT request.

    deleteWithFriend:
      method: 'delete'
      url: "#{listUrl}/friend"
      headers: 'Content-Type': 'application/json;charset=utf-8'
    ###

module.exports = Friendship
