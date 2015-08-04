class RequestPushCtrl
  constructor: (localStorageService, @$cordovaPush, @$cordovaDevice, @Auth, @APNSDevice) ->
    @localStorage = localStorageService

  enablePush: ->
    @localStorage.set 'hasRequestedPushNotifications', true
    # iOS Notification Permissions Options
    iosConfig =
      badge: true
      sound: true
      alert: true
    @$cordovaPush.register iosConfig
      .then (deviceToken) =>
        @saveToken deviceToken
      , =>
        @Auth.redirectForAuthState()

  saveToken: (deviceToken)->
    device = @$cordovaDevice.getDevice()
    name = device.model + ', ' + device.version
    apnsDevice =
      user: @Auth.user.id
      registration_id: deviceToken
      device_id: device.UUID
      name: name
    @APNSDevice.save apnsDevice
      .$promise.then =>
        @Auth.redirectForAuthState()
      , =>
        # TODO : Show An Error
        console.log "An Error"

module.exports = RequestPushCtrl
