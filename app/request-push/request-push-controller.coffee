class RequestPushCtrl
  constructor: (@$cordovaPush, @$cordovaDevice, @Auth, @APNSDevice,
                localStorageService) ->
    @localStorage = localStorageService

  enablePush: ->
    # iOS Notification Permissions Options
    iosConfig =
      badge: true
      sound: true
      alert: true
    @$cordovaPush.register iosConfig
      .then (deviceToken) =>
        @localStorage.set 'hasRequestedPushNotifications', true
        @saveToken deviceToken
      , (error) =>
        @localStorage.set 'hasRequestedPushNotifications', true
        @Auth.redirectForAuthState()

  saveToken: (deviceToken)->
    device = @$cordovaDevice.getDevice()
    name = "#{device.model}, #{device.version}"
    apnsDevice =
      userId: @Auth.user.id
      registrationId: deviceToken
      deviceId: device.uuid
      name: name
    @APNSDevice.save apnsDevice
      .$promise.then =>
        @Auth.redirectForAuthState()
      , =>
        # TODO : Show An Error
        console.log 'error saving the apns device'

module.exports = RequestPushCtrl
