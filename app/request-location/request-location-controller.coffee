class RequestLocationCtrl
  constructor: (@$state, @localStorageService, @Auth) ->
    @localStorage = @localStorageService

  enableLocation: ->
    @Auth.watchLocation().then =>
      @localStorage.set 'hasRequestedLocationServices', true
      @Auth.redirectForAuthState()
    , =>
      # TODO
      @localStorage.set 'hasRequestedLocationServices', true

module.exports = RequestLocationCtrl
