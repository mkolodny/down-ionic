class VerifyPhoneCtrl
  constructor: (@$scope, @$state, @Auth, localStorageService, @User) ->
    @localStorage = localStorageService

  authenticate: ->
    if not @validate()
      return

    @Auth.authenticate @Auth.phone, @code
      .then (user) =>
        # Auth successful
        @Auth.redirectForAuthState()

      , (status) =>
        # Auth failed
        if status is 500
          @error = 'Looks like you entered the wrong code :('
        else
          @error = 'Oops, something went wrong.'

  validate: ->
    @$scope.verifyPhoneForm.$valid

module.exports = VerifyPhoneCtrl
