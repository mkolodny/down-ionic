class VerifyPhoneCtrl
  constructor: (@$scope, @$state, @Auth, localStorageService, @User) ->
    @localStorage = localStorageService

  authenticate: ->
    if not @validate()
      return

    # TODO: handle when the user doesn't have location services turned on. Use
    # the cordova geolocation plugin's getCurrentPosition function.
    @Auth.authenticate @Auth.phone, @code
      .then (user) =>
        # Auth successful
        if not user.email?
          @$state.go 'facebookSync'
        else if not user.username?
          @$state.go 'setUsername'
        else if not @localStorage.get 'hasAllowedLocationServices'
          @$state.go 'requestLocation'
        else if not @localStorage.get 'hasAllowedPushNotifications'
          @$state.go 'requestPush'
        else
          @$state.go 'events'

      , (status) =>
        # Auth failed
        if status is 500
          @error = 'Looks like you entered the wrong code :('
        else
          @error = 'Oops, something went wrong.'

  validate: ->
    @$scope.verifyPhoneForm.$valid

module.exports = VerifyPhoneCtrl
