class FriendsCtrl
  @$inject: ['$ionicHistory', '$state', 'Auth', 'Points']
  constructor: (@$ionicHistory, @$state, @Auth, @Points) ->
    @currentUser = @Auth.user

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
