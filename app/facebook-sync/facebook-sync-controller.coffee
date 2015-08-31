class FacebookSyncCtrl
  constructor: (@$cordovaFacebook, @$ionicLoading, @$state, @Auth) ->

  syncWithFacebook: ->
    permissions = ['email', 'user_friends', 'public_profile']
    @$cordovaFacebook.login permissions
      .then (response) =>
        @$ionicLoading.show
          template: '''
            <div class="loading-text">Syncing...</div>
            <ion-spinner icon="bubbles"></ion-spinner>
            '''

        @Auth.syncWithFacebook response.authResponse.accessToken
      .then (user) =>
        @Auth.setUser user
        @$state.go 'setUsername'
      , (error) =>
        @error = 'Oops, something went wrong. Please try again.'
      .finally =>
        @$ionicLoading.hide()

module.exports = FacebookSyncCtrl
