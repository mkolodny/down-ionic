class AddFriendsCtrl
  constructor: (@$state) ->

  addByUsername: ->
    @$state.go 'addByUsername'

  addFromAddressBook: ->
    @$state.go 'addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'addFromFacebook'

module.exports = AddFriendsCtrl
