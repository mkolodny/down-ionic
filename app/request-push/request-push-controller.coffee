class RequestPushCtrl
  constructor: (@$ionicLoading, @Auth, @PushNotifications,
                localStorageService) ->
    @localStorage = localStorageService

  enablePush: ->
    @$ionicLoading.show
      template: '''
        <div class="loading-text">Enabling push notifications...</div>
        <ion-spinner icon="bubbles"></ion-spinner>
        '''

    requestedFlag = 'hasRequestedPushNotifications'
    @PushNotifications.register().then null, null
    .finally =>
      @localStorage.set requestedFlag, true
      @Auth.redirectForAuthState()
      @$ionicLoading.hide()

module.exports = RequestPushCtrl
