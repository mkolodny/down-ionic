class RequestLocationCtrl
  constructor: (@$state, @localStorageService, @Auth) ->
    @localStorage = @localStorageService

  enableLocation: ->
    @Auth.watchLocation().then =>
      @Auth.redirectForAuthState()
    , =>
      # TODO
      null
    .finally =>
      @localStorage.set 'hasRequestedLocationServices', true

module.exports = RequestLocationCtrl
