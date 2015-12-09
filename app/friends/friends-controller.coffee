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
    inviteLink = 'http://rallytap.com'
    @$cordovaSocialSharing.share inviteMessage, inviteMessage, null, inviteLink
      .then (confirmedShare) =>
        @$mixpanel.track 'Share App',
          'confirmed share': confirmedShare


module.exports = FriendsCtrl
