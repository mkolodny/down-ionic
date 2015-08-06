class RequestContactsCtrl
  constructor: (@$state) ->

  requestContacts: ->
  	@$state.go 'findFriends'

module.exports = RequestContactsCtrl
