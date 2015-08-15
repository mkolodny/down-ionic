class VerifyPhoneCtrl
  constructor: (@$scope, @$state, @Asteroid, @Auth, localStorageService, @User) ->
    @localStorage = localStorageService

  authenticate: ->
    if not @validate()
      return

    @Auth.authenticate @Auth.phone, @code
      .then (user) =>
        @Auth.setUser user
        @meteorLogin()
      , (status) =>
        # Auth failed
        if status is 500
          @error = 'Looks like you entered the wrong code :('
        else
          @error = 'Oops, something went wrong.'

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
