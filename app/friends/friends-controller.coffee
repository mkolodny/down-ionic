class FriendsCtrl
  @$inject: ['$ionicHistory', '$state']
  constructor: (@$ionicHistory, @$state) ->

  showMyFriends: ->
    @$state.go 'myFriends'

  showAddedMe: ->
    @$state.go 'addedMe'

  addByUsername: ->
    @$state.go 'addByUsername'

  addFromAddressBook: ->
    @$state.go 'addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'addFromFacebook'

  addByPhone: ->
    @$state.go 'addByPhone'

module.exports = FriendsCtrl
