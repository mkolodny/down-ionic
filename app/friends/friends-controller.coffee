class FriendsCtrl
  @$inject: ['$ionicHistory', '$state', 'Auth']
  constructor: (@$ionicHistory, @$state, @Auth) ->
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
