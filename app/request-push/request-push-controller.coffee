class RequestPushCtrl
  @$inject: ['$cordovaDevice', '$cordovaPush', 'PushNotifications', 'Auth']
  constructor: (@$cordovaDevice, @$cordovaPush, @PushNotifications, @Auth) ->

  enablePush: ->
    @PushNotifications.register()
    @Auth.setFlag 'hasRequestedPushNotifications', true
    @Auth.redirectForAuthState()

module.exports = RequestPushCtrl
