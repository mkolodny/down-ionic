Friendship = ['$http', '$meteor', '$q', '$resource', 'apiRoot', 'Auth', \
              ($http, $meteor, $q, $resource, apiRoot, Auth) ->
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

  resource.sendMessage = (friend, text) ->
    friendId = friend.id
    # Save the message on the meteor server.
    Messages = $meteor.getCollectionByName 'messages'
    Messages.insert
      creator:
        id: "#{Auth.user.id}" # Meteor likes strings
        name: Auth.user.name
        firstName: Auth.user.firstName
        lastName: Auth.user.lastName
        imageUrl: Auth.user.imageUrl
      text: text
      chatId: @getChatId friendId
      type: 'text'
      createdAt: new Date()

    # Save the message on the django server.
    url = "#{listUrl}/#{friendId}/messages"
    requestData = {text: text}
    $http.post url, requestData

  resource.getChatId = (friendId) ->
    if Auth.user.id < friendId
      "#{Auth.user.id},#{friendId}"
    else
      "#{friendId},#{Auth.user.id}"

  resource.parseChatId = (chatId) ->
    ids = chatId.split ','
    if ids[0] is "#{Auth.user.id}"
      ids[1]
    else
      ids[0]

  resource
]

module.exports = Friendship
