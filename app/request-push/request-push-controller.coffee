class RequestPushCtrl
  constructor: (@$cordovaPush, @$cordovaDevice, @$ionicLoading, @Auth, @APNSDevice,
                localStorageService) ->
    @localStorage = localStorageService

  enablePush: ->
    # iOS Notification Permissions Options
    iosConfig =
      badge: true
      sound: true
      alert: true
    requestedFlag = 'hasRequestedPushNotifications'
    @$cordovaPush.register iosConfig
      .then (deviceToken) =>
        @localStorage.set requestedFlag, true
        @saveToken deviceToken
      , (error) =>
        @localStorage.set requestedFlag, true
        @Auth.redirectForAuthState()

  saveToken: (deviceToken)->
    @$ionicLoading.show
      template: '''
        <div class="loading-text">Enabling push notifications...</div>
        <ion-spinner icon="bubbles"></ion-spinner>
        '''

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
      .finally =>
        @$ionicLoading.hide()

module.exports = RequestPushCtrl
