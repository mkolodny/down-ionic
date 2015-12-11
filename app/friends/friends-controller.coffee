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

  showAddFriends: ->
    @$state.go 'addFriends'

  hasSharePlugin: ->
    angular.isDefined @$window.plugins?.socialsharing

  shareApp: ->
    inviteMessage = 'Hey! Have you tried Rallytap?'
    inviteLink = 'https://rallytap.com'
    @$cordovaSocialSharing.share inviteMessage, inviteMessage, null, inviteLink
      .then =>
        @$mixpanel.track 'Share App'


module.exports = FriendsCtrl
