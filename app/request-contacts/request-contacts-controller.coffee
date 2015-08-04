class RequestContactsCtrl
  constructor: (@Auth) ->

  requestContacts: ->
    @Auth.redirectForAuthState()

module.exports = RequestContactsCtrl
