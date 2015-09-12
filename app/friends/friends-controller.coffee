class FriendsCtrl
  @$inject: ['$ionicHistory', '$state']
  constructor: (@$ionicHistory, @$state) ->

  showMyFriends: ->
    @$state.go 'myFriends'

  addByUsername: ->
    @$state.go 'addByUsername'

  addFromAddressBook: ->
    @$state.go 'addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'addFromFacebook'

  goBack: ->
    # Don't animate the transition to the events view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

    @$state.go 'events'

module.exports = FriendsCtrl
