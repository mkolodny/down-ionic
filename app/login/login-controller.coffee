class LoginCtrl
  constructor: (@$scope, @$state, @Auth) ->

  login: ->
    if not @validate()
      return

    @Auth.sendVerificationText(@phone).then =>
      @$state.go 'down.verifyPhone'
    , =>
      @error = 'For some reason, that didn\'t work'

  validate: ->
    @$scope.loginForm.$valid

module.exports = LoginCtrl
