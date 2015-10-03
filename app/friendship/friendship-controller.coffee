class FriendshipCtrl
  @$inject: ['$mixpanel', '$stateParams', 'Auth', 'Invitation', 'Friendship']
  constructor: (@$mixpanel, @$stateParams, @Auth, @Invitation, @Friendship) ->
    @friend = @$stateParams.friend

  isActionMessage: (message) ->
    actions = [
      @Invitation.acceptAction
      @Invitation.maybeAction
      @Invitation.declineAction
    ]
    message.type in actions

  isMyMessage: (message) ->
    message.creator.id is "#{@Auth.user.id}"

  sendMessage: ->
    @Friendship.sendMessage @friend, @message
    @$mixpanel.track 'Send Message',
      to: 'friend'
    @message = null

module.exports = FriendshipCtrl
