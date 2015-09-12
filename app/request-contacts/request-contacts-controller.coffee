class RequestContactsCtrl
  @$inject: ['$state']
  constructor: (@$state) ->

  requestContacts: ->
  	@$state.go 'findFriends'

module.exports = RequestContactsCtrl
