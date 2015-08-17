class FacebookSyncCtrl
  constructor: (@$cordovaFacebook, @$state, @Auth) ->

  syncWithFacebook: ->
    permissions = ['email', 'user_friends', 'public_profile']
    @$cordovaFacebook.login permissions
      .then (response) =>
        @Auth.syncWithFacebook response.authResponse.accessToken
      .then (user) =>
        @Auth.setUser user
        @$state.go 'setUsername'
      , (error) =>
        @error = 'Oops, something went wrong. Please try again.'

module.exports = FacebookSyncCtrl
