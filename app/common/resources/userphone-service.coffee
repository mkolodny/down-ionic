UserPhone = ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/userphones"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        user = data.user
        request =
          user:
            id: user.id
            email: user.email
            name: user.name
            username: user.username
            image_url: user.imageUrl
            location:
              type: 'Point'
              coordinates: [user.location.lat, user.location.long]
          phone: data.phone
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        user = data.user
        console.log user
        response =
          id: data.id
          user:
            id: user.id
            email: user.email
            name: user.name
            username: user.username
            imageUrl: user.image_url
            location:
              lat: user.location.coordinates[0]
              long: user.location.coordinates[1]
          phone: data.phone
        response

module.exports = UserPhone
