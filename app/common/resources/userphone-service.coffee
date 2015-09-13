require '../../vendor/intl-phone/libphonenumber-utils.js'

UserPhone = ['$http', '$q', '$resource', 'apiRoot', 'Auth', 'localStorageService', \
             'User', \
             ($http, $q, $resource, apiRoot, Auth, localStorageService, User) ->
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

    getFromContacts:
      method: 'post'
      url: "#{listUrl}/contacts"
      isArray: true
      transformRequest: (data, headersGetter) ->
        request = {contacts: data}
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response = ({
          user: User.deserialize userphone.user
          phone: userphone.phone
        } for userphone in data)
        response
]

module.exports = UserPhone
