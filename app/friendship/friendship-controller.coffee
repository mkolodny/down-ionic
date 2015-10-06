class FriendshipCtrl
  @$inject: ['$ionicLoading', '$ionicScrollDelegate', '$meteor', '$mixpanel', '$scope', '$state',
             '$stateParams', 'Auth', 'Invitation', 'Friendship', 'ngToast', 'User']
  constructor: (@$ionicLoading, @$ionicScrollDelegate, @$meteor, @$mixpanel, @$scope, @$state,
                @$stateParams, @Auth, @Invitation, @Friendship, @ngToast, @User) ->
    @friend = @$stateParams.friend

    # Set Meteor collections on controller
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'

    @$scope.$on '$ionicView.beforeEnter', =>
      # Don't scroll to the bottom until view fully enters
      @shouldScrollBottom = false

      @getFriendInvitations()

      @chatId = @Friendship.getChatId @friend.id

      # Subscribe to the event's chat.
      @$scope.$meteorSubscribe 'chat', @chatId

      # Bind reactive variables
      @messages = @$meteor.collection @getMessages, false

      # Mark messages as read as they come in.
      @$scope.$watch =>
        newestMessage = @messages[@messages.length-1]
        if angular.isDefined newestMessage
          newestMessage._id
      , @handleNewMessage

    @$scope.$on '$ionicView.leave', =>
      # Remove angular-meteor bindings.
      @messages.stop()

  handleNewMessage: (newMessageId) =>
    if newMessageId is undefined
      return

    @$meteor.call 'readMessage', newMessageId
    @scrollBottom()

    # If the newest message is an invite action, attach the invitation to the
    #   message.
    newestMessage = @messages[@messages.length-1]
    if newestMessage.type is @Invitation.inviteAction
      @getFriendInvitations()

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


        for message in @messages
          if message.type is @Invitation.inviteAction
            invitation = events[message.meta.eventId]
            if angular.isDefined invitation
              message.invitation = invitation
            else
              # Delete expired invite_action message
              @messages.remove message._id

        @scrollBottom()
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

  isInviteAction: (message) ->
    message.type is @Invitation.inviteAction

  isTextMessage: (message) ->
    message.type is @Invitation.textMessage

  isLoadingInvitation: (message) ->
    message.type is @Invitation.inviteAction and message.invitation is undefined

  isErrorAction: (message) ->
    message.type is @Invitation.errorAction

  isMyMessage: (message) ->
    message.creator.id is "#{@Auth.user.id}"

  isAccepted: (invitation) ->
    invitation.response is @Invitation.accepted

  isMaybe: (invitation) ->
    invitation.response is @Invitation.maybe

  isDeclined: (invitation) ->
    invitation.response is @Invitation.declined

  wasJoined: (message) ->
    message.invitation.response is @Invitation.accepted \
        or message.invitation.response is @Invitation.maybe

  respondToInvitation: (invitation, response) ->
    @$ionicLoading.show()

    @Invitation.updateResponse invitation, response
      .$promise.then (invitation) =>
        if invitation.response in [@Invitation.accepted, @Invitation.maybe]
          @$state.go 'event',
            invitation: invitation
            id: invitation.event.id
      , =>
        @ngToast.create 'For some reason, that didn\'t work.'
      .finally =>
        @$ionicLoading.hide()

  acceptInvitation: (invitation) ->
    @respondToInvitation invitation, @Invitation.accepted

  maybeInvitation: (invitation) ->
    @respondToInvitation invitation, @Invitation.maybe

  declineInvitation: (invitation) ->
    @respondToInvitation invitation, @Invitation.declined

  viewEvent: (invitation) ->
    @$state.go 'event',
      invitation: invitation
      id: invitation.event.id

  sendMessage: ->
    @Friendship.sendMessage @friend, @message
    @$mixpanel.track 'Send Message',
      'chat type': 'friend'
    @message = null

  scrollBottom: ->
    @$ionicScrollDelegate.$getByHandle('friendship')
      .scrollBottom true


module.exports = FriendshipCtrl
