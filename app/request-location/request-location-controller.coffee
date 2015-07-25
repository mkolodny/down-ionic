class RequestLocationCtrl
  constructor: (@$state, @localStorageService, @Auth)->
    @localStorage = @localStorageService

  enableLocation: () ->
    @localStorage.set 'hasRequestedLocationServices', true
    @Auth.watchLocation().then ()->


module.exports = RequestLocationCtrl
