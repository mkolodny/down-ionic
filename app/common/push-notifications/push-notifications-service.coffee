class PushNotifications
  constructor: (@$cordovaDevice, @$cordovaPush, @$q,
               @Auth, @APNSDevice, localStorageService) ->
    @localStorage = localStorageService

  register: ->
    deferred = @$q.defer()

    # iOS Notification Permissions Options
    iosConfig =
      badge: true
      sound: true
      alert: true
    @$cordovaPush.register iosConfig
      .then (deviceToken) =>
        @saveToken deviceToken
      , (error) =>
        deferred.reject()

    return deferred.promise

  saveToken: (deviceToken)->
    deferred = @$q.defer()

    device = @$cordovaDevice.getDevice()
    name = "#{device.model}, #{device.version}"
    apnsDevice =
      userId: @Auth.user.id
      registrationId: deviceToken
      deviceId: device.uuid
      name: name
    @APNSDevice.save apnsDevice
      .$promise.then =>
        deferred.resolve()
      .finally =>
        deferred.reject()

    return deferred.promise

module.exports = PushNotifications
