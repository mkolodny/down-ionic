class PushNotifications
  constructor: (@$cordovaDevice, @$cordovaPush, @$q,
               @Auth, @APNSDevice, localStorageService) ->
    @localStorage = localStorageService

  register: ->
    deferred = @$q.defer()

    platform = @$cordovaDevice.getPlatform()
    config = null
    if platform is 'iOS'
      # iOS Notification Permissions Options
      config =
        badge: true
        sound: true
        alert: true
    else if platform is 'Android'
      # Android Notification permissions options
      config =
        senderId: @androidSenderId

    @$cordovaPush.register config
      .then (deviceToken) =>
        @saveToken deviceToken
      , (error) =>
        deferred.reject()

    return deferred.promise

  saveToken: (deviceToken)->
    deferred = @$q.defer()

    device = @$cordovaDevice.getDevice()
    name = "#{device.model}, #{device.version}"

    if device.platform is 'iOS'
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
    # else if device.platform is 'Android'
      # TODO : use GCMDevice to save to DJANGO!

    return deferred.promise

module.exports = PushNotifications
