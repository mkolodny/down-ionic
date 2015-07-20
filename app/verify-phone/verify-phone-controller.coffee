class VerifyPhoneCtrl
  constructor: (@$state, @Auth, @User) ->

  authenticate: ->
    @Auth.authenticate @Auth.phone, @code
      .then (user) =>
        # Auth successful
        if !user?.email
          @$state.go 'down.syncWithFacebook' 

      , (response) =>
        # Auth failed, show error
        console.log "AUTH FAILED"

module.exports = VerifyPhoneCtrl