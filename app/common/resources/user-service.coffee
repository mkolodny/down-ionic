User = ['$http', '$q', '$resource', 'apiRoot', ($http, $q, $resource, apiRoot) ->
  listUrl = "#{apiRoot}/users"
  serializeUser = (user) ->
    data =
      id: user.id
      email: user.email
      name: user.name
      username: user.username
      image_url: user.imageUrl
    if user.location?
      data.location =
        type: 'Point'
        coordinates: [user.location.lat, user.location.long]
    if user.firstName?
      data.first_name = user.firstName
    if user.lastName?
      data.last_name = user.lastName
    data
  deserializeUser = (data) ->
    user =
      id: data.id
      email: data.email
      name: data.name
      username: data.username
      imageUrl: data.image_url
    if data.first_name?
      user.firstName = data.first_name
    if data.last_name?
      user.lastName = data.last_name
    if data.location?
      user.location =
        lat: data.location.coordinates[0]
        long: data.location.coordinates[1]
    if data.authtoken?
      user.authtoken = data.authtoken
    if data.friends?
      user.friends = {}
      for friend in data.friends
        friend = deserializeUser friend
        user.friends[friend.id] = friend
    if data.facebook_friends?
      user.facebookFriends = {}
      for friend in data.facebook_friends
        friend = deserializeUser friend
        user.facebookFriends[friend.id] = friend
    new resource user

  resource = $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request = serializeUser data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeUser data

    update:
      method: 'put'
      params:
        id: '@id'
      transformRequest: (data, headersGetter) ->
        request = serializeUser data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeUser data

    get:
      method: 'get'
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeUser data

    query:
      method: 'get'
      isArray: true
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        (deserializeUser(user) for user in data)

  resource.listUrl = listUrl

  resource.serialize = serializeUser
  resource.deserialize = deserializeUser

  resource.isUsernameAvailable = (username) ->
    deferred = $q.defer()

    $http.get "#{listUrl}/username/#{username}"
      .success (data, status) ->
        deferred.resolve false
      .error (data, status) ->
        if status is 404
          deferred.resolve true
        else
          deferred.reject()

    deferred.promise

  resource::getImageUrl = (size = 100) ->
    "#{@imageUrl}?width=#{size}&height=#{size}"

  resource
]

module.exports = User
