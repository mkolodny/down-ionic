class RequestPushCtrl
  @$inject: ['$cordovaDevice', '$cordovaPush', 'PushNotifications', 'Auth',
             'localStorageService']
  constructor: (@$cordovaDevice, @$cordovaPush, @PushNotifications, @Auth,
                localStorageService) ->
    @localStorage = localStorageService

  enablePush: ->
    @PushNotifications.register()
    @localStorage.set 'hasRequestedPushNotifications', true
    @Auth.redirectForAuthState()


module.exports = RequestPushCtrl
