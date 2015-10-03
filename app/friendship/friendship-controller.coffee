class FriendshipCtrl
  @$inject: ['$meteor', '$mixpanel', '$scope', '$stateParams', 'Auth',
             'Invitation', 'Friendship', 'User']
  constructor: (@$meteor, @$mixpanel, @$scope, @$stateParams, @Auth, @Invitation,
                @Friendship, @User) ->
    @friend = @$stateParams.friend

    @$scope.$on '$ionicView.enter', =>
      # Subscribe to the chat messages.
      @chatId = @Friendship.getChatId @friend.id
      @chat = @$scope.$meteorSubscribe 'chat', @chatId
      @messages = @$meteor.collection @getMessages, false

      @$scope.$watch =>
        newestMessage = @messages[@messages.length-1]
        if angular.isDefined newestMessage
          newestMessage._id
      , (newValue, oldValue) =>
        @$meteor.call 'readMessage', newValue

    @$scope.$on '$ionicView.leave', =>
      # Remove angular-meteor bindings.
      @messages.stop()
      @chat.stop()

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
