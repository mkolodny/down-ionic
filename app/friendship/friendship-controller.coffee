class FriendshipCtrl
  @$inject: ['$meteor', '$mixpanel', '$scope', '$stateParams', 'Auth',
             'Invitation', 'Friendship', 'User']
  constructor: (@$meteor, @$mixpanel, @$scope, @$stateParams, @Auth, @Invitation,
                @Friendship, @User) ->
    @friend = @$stateParams.friend

    # Set Meteor collections on controller
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'

    @$scope.$on '$ionicView.enter', =>
      @getFriendInvitations()

      # Subscribe to the chat messages.
      @chatId = @Friendship.getChatId @friend.id
      @chat = @$scope.$meteorSubscribe 'chat', @chatId
      @messages = @$meteor.collection @getMessages, false

      # Mark messages as read as they come in.
      @$scope.$watch =>
        newestMessage = @messages[@messages.length-1]
        if angular.isDefined newestMessage
          newestMessage._id
      , (newValue, oldValue) =>
        if newValue is undefined
          return

        @$meteor.call 'readMessage', newValue

        # If the newest message is an invite action, attach the invitation to the
        #   message.
        newestMessage = @messages[@messages.length-1]
        if newestMessage.type is @Invitation.inviteAction
          @getFriendInvitations()

    @$scope.$on '$ionicView.leave', =>
      # Remove angular-meteor bindings.
      @messages.stop()

  ###
  # Get the active invitations to/from the friend.
  ###
  getFriendInvitations: ->
    @Invitation.getUserInvitations @friend.id
      .$promise.then (invitations) =>
        # Set the invitations on their corresponding messages objects. If an
        #   invite action message exists without a corresponding invitation,
        #   remove the message.
        events = {}
        for invitation in invitations
          events[invitation.eventId] = invitation

        messages = []
        for message in @messages
          if message.type is @Invitation.inviteAction
            invitation = events[message.meta.eventId]
            if angular.isDefined invitation
              message.invitation = invitation
              messages.push message
          else
            messages.push message
        @messages = messages
      , =>
        # Change all invitation action messages to error action messages.
        for message in @messages
          if message.type is @Invitation.inviteAction
            message.type = @Invitation.errorAction

  getMessages: =>
    @Messages.find
      chatId: @chatId
    ,
      sort:
        createdAt: 1
      transform: @transformMessage

  transformMessage: (message) =>
    message.creator = new @User message.creator
    message

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
