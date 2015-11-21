class FriendsCtrl
  @$inject: ['$ionicHistory', '$state']
  constructor: (@$ionicHistory, @$state) ->

  showMyFriends: ->
    @$state.go 'friends.myFriends'

  showAddedMe: ->
    @$state.go 'friends.addedMe'

  addByUsername: ->
    @$state.go 'friends.addByUsername'

  addFromAddressBook: ->
    @$state.go 'friends.addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'friends.addFromFacebook'

  addByPhone: ->
    @$state.go 'friends.addByPhone'

module.exports = FriendsCtrl
