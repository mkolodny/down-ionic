class VerifyPhoneCtrl
  constructor: (@$state, @Auth, localStorageService, @User) ->
    @localStorage = localStorageService

  authenticate: ->
    # TODO: handle validation (check login-controller/html for an example)
    # TODO: handle when the user doesn't have location services turned on. Use
    # the cordova geolocation plugin's getCurrentPosition function.
    @Auth.authenticate @Auth.phone, @code
      .then (user) =>
        # Auth successful
        if not user.email?
          @$state.go 'facebookSync'
        else if not user.username?
          @$state.go 'setUsername'
        else if not @localStorage.get 'hasAllowedPushNotifications'
          @$state.go 'requestPushServices'
        else
          @$state.go 'events'

      , (status) =>
        # Auth failed
        if status is 500
          @error = 'Looks like you entered the wrong code :('
        else
          @error = 'Oops, something went wrong.'

module.exports = VerifyPhoneCtrl
