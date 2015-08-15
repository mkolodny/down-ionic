class VerifyPhoneCtrl
  constructor: (@$ionicLoading, @$scope, @$state, @Asteroid, @Auth,
                localStorageService, @User) ->
    @localStorage = localStorageService

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
        @Auth.setUser user
        @meteorLogin()
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

  meteorLogin: ->
    @Asteroid.login().then =>
      @getFacebookFriends()
    , =>
      @error = 'Oops, something went wrong.'

  getFacebookFriends: ->
    @User.getFacebookFriends()
      .$promise.then (friends) =>
        @Auth.user.facebookFriends = friends
        @Auth.redirectForAuthState()
      , (error) =>
        if error?.status is 400
          @$state.go 'facebookSync'
        else
          @error = 'Oops, something went wrong.'



module.exports = VerifyPhoneCtrl
