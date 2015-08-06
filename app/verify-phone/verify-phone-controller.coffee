class VerifyPhoneCtrl
  constructor: (@$scope, @$state, @Asteroid, @Auth, localStorageService, @User) ->
    @localStorage = localStorageService

  authenticate: ->
    if not @validate()
      return

    @Auth.authenticate @Auth.phone, @code
      .then (user) =>
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
      @Auth.redirectForAuthState()
    , =>
      @error = 'Oops, something went wrong.'

module.exports = VerifyPhoneCtrl
