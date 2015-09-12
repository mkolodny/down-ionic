class VerifyPhoneCtrl
  @$inject: ['$ionicLoading', '$scope', '$state', 'Asteroid', 'Auth']
  constructor: (@$ionicLoading, @$scope, @$state, @Asteroid, @Auth) ->

  authenticate: ->
    if not @validate()
      return

    @$ionicLoading.show
      template: '''
        <div class="loading-text">Logging you in...</div>
        <ion-spinner icon="bubbles"></ion-spinner>
        '''

    # TODO: Refactor this to chain promises.
    phone = @Auth.phone
    @Auth.authenticate phone, @code
      .then (user) =>
        @Auth.setPhone phone
        @meteorLogin user
      , (status) =>
        # Auth failed
        if status is 500
          @error = 'Looks like you entered the wrong code :('
        else
          @error = 'Oops, something went wrong.'
      .finally =>
        @$ionicLoading.hide()

  validate: ->
    @$scope.verifyPhoneForm.$valid

  meteorLogin: (user) ->
    @Asteroid.login().then =>
      # Persist the user to local storage.
      @Auth.setUser user
      if user.email is undefined
        @$state.go 'facebookSync'
      else
        # The user has synced with Facebook.
        @getFacebookFriends()
    , =>
      @error = 'Oops, something went wrong.'

  getFacebookFriends: ->
    @Auth.getFacebookFriends()
      .$promise.then (facebookFriends) =>
        @Auth.user.facebookFriends = facebookFriends
        # Persist the user to local storage.
        @Auth.setUser @Auth.user
        @Auth.redirectForAuthState()
      , (error) =>
        if error is 'MISSING_SOCIAL_ACCOUNT'
          @$state.go 'facebookSync'
        else
          @error = 'Oops, something went wrong.'

module.exports = VerifyPhoneCtrl
