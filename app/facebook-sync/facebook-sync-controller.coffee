class FacebookSyncCtrl
  constructor: (@$cordovaOauth, @$state, @fbClientId, @Auth) ->

  syncWithFacebook: ->
    permissions = ['email', 'user_friends', 'public_profile']
    @$cordovaOauth.facebook(@fbClientId, permissions).then (response) =>
      @Auth.syncWithFacebook(response.access_token).then (user) =>
        @Auth.user = angular.extend @Auth.user, user
        @$state.go 'setUsername'
      , =>
        @error = 'Oops, something went wrong. Please try again.'
    , =>
      @error = 'It looks like you declined syncing with Facebook :('

module.exports = FacebookSyncCtrl
