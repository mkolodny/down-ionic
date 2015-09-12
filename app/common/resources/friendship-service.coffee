Friendship = ['$http', '$q', '$resource', 'apiRoot', 'Auth', \
              ($http, $q, $resource, apiRoot, Auth) ->
  listUrl = "#{apiRoot}/friendships"

  resource = $resource "#{listUrl}/:id", null,
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

  resource.deleteWithFriendId = (friendId) ->
    deferred = $q.defer()

    $http
      method: 'delete'
      url: "#{listUrl}/friend"
      data:
        friend: friendId
      headers:
        'Content-Type': 'application/json;charset=utf-8'
    .success (data, status, headers, config) ->
      deferred.resolve()
    .error (data, status, headers, config) ->
      deferred.reject()

    {$promise: deferred.promise}

  resource
]

module.exports = Friendship
