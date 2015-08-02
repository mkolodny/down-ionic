UserPhone = ($resource, apiRoot, User) ->
  listUrl = "#{apiRoot}/userphones"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          user: User.serialize data.user
          phone: data.phone
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          user: User.deserialize data.user
          phone: data.phone
        response

    getFromPhones:
      method: 'post'
      # url: "#{listUrl}/phones"
      # isArray: true

module.exports = UserPhone
