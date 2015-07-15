APNSDevice = ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/apnsdevices"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          userId: data.user_id
          registrationId: data.registration_id
          deviceId: data.device_id
          name: data.name
        response

module.exports = APNSDevice
