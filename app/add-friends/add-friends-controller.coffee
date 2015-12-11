class AddFriendsCtrl
  @$inject: ['$state']
  constructor: (@$state) ->

  addByUsername: ->
    @$state.go 'addByUsername'

  addFromAddressBook: ->
    @$state.go 'addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'addFromFacebook'

  addByPhone: ->
    @$state.go 'addByPhone'


module.exports = AddFriendsCtrl
