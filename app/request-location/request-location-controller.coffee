class RequestLocationCtrl
  @$inject: ['$state', 'Auth', 'localStorageService']
  constructor: (@$state, @Auth, localStorageService) ->
    @localStorage = localStorageService

  enableLocation: ->
    @Auth.watchLocation()
      .then =>
        @localStorage.set 'hasRequestedLocationServices', true
        @Auth.redirectForAuthState()
      , =>
        @locationDenied = true

module.exports = RequestLocationCtrl
