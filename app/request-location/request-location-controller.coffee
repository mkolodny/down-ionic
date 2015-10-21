class RequestLocationCtrl
  @$inject: ['$state', 'Auth']
  constructor: (@$state, @Auth) ->

  enableLocation: ->
    @Auth.watchLocation()
      .then =>
        @Auth.setFlag 'hasRequestedLocationServices', true
        @Auth.redirectForAuthState()
      , =>
        @locationDenied = true

module.exports = RequestLocationCtrl
