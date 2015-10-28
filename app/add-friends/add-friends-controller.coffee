class AddFriendsCtrl
  @$inject: ['$ionicHistory', '$state']
  constructor: (@$ionicHistory, @$state) ->

  addByUsername: ->
    @$state.go 'addByUsername'

  addFromAddressBook: ->
    @$state.go 'addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'addFromFacebook'

  addByPhone: ->
    @$state.go 'addByPhone'

  goBack: ->
    # Don't animate the transition to the events view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

    @$ionicHistory.goBack()

module.exports = AddFriendsCtrl
