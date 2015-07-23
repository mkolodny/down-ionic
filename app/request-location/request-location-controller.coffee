class RequestLocationCtrl
  constructor: ($state, localStorageService)->
    @localStorage = localStorageService

  enableLocation: () ->
    @localStorage.hasAllowedLocationServices = true

module.exports = RequestLocationCtrl
