class AddFriendsCtrl
  @$inject: ['$ionicHistory', '$state']
  constructor: (@$ionicHistory, @$state) ->

  addByUsername: ->
    @$state.go 'tabs.friends.addByUsername'

  addFromAddressBook: ->
    @$state.go 'tabs.friends.addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'tabs.friends.addFromFacebook'

  addByPhone: ->
    @$state.go 'tabs.friends.addByPhone'

  goBack: ->
    # Don't animate the transition to the events view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

    @$ionicHistory.goBack()

module.exports = AddFriendsCtrl
