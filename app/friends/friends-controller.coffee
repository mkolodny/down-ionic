class FriendsCtrl
  @$inject: ['$ionicHistory', '$state']
  constructor: (@$ionicHistory, @$state) ->

  showMyFriends: ->
    @$state.go 'tabs.friends.myFriends'

  showAddedMe: ->
    @$state.go 'tabs.friends.addedMe'

  addByUsername: ->
    @$state.go 'tabs.friends.addByUsername'

  addFromAddressBook: ->
    @$state.go 'tabs.friends.addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'tabs.friends.addFromFacebook'

  addByPhone: ->
    @$state.go 'tabs.friends.addByPhone'

module.exports = FriendsCtrl
