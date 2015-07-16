User = ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/users"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          email: data.email
          name: data.name
          username: data.username
          image_url: data.imageUrl
          location:
            type: 'Point'
            coordinates: [data.location.lat, data.location.long]
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          email: data.email
          name: data.name
          username: data.username
          imageUrl: data.image_url
          location:
            lat: data.location.coordinates[0]
            long: data.location.coordinates[1]
          authtoken: data.authtoken
          firebaseToken: data.firebase_token
        response

module.exports = User
