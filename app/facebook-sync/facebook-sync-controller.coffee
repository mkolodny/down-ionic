class FacebookSyncCtrl
  constructor: (@$cordovaOauth, @$state, @fbClientId, @Auth) ->

  syncWithFacebook: ->
    permissions = ['email', 'user_friends', 'public_profile']
    @$cordovaOauth.facebook @fbClientId, permissions
      .then (response) =>
        @Auth.syncWithFacebook response.access_token
      .then (user) =>
        @Auth.setUser user
        @$state.go 'setUsername'
      , (error) =>
        @error = 'Oops, something went wrong. Please try again.'

module.exports = FacebookSyncCtrl
