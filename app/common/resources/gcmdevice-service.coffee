GCMDevice = ['$resource', 'apiRoot', ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/devices/gcm"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          user: data.userId
          registration_id: data.registrationId
          device_id: data.deviceId
          name: data.name
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          userId: data.user
          registrationId: data.registration_id
          deviceId: data.device_id
          name: data.name
        response
]

module.exports = GCMDevice
