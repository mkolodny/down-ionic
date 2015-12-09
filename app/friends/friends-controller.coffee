class FriendsCtrl
  @$inject: ['$cordovaSocialSharing', '$ionicHistory', '$state', \
             '$mixpanel', '$window', 'Auth', 'Points']
  constructor: (@$cordovaSocialSharing, @$ionicHistory, @$state, 
                @$mixpanel, @$window, @Auth, @Points) ->
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

  hasSharePlugin: ->
    angular.isDefined @$window.plugins?.socialsharing

  shareApp: ->
    inviteMessage = 'Hey! Have you tried Rallytap?'
    inviteLink = 'https://rallytap.com'
    @$cordovaSocialSharing.share inviteMessage, inviteMessage, null, inviteLink
      .then =>
        @$mixpanel.track 'Share App'


module.exports = FriendsCtrl
