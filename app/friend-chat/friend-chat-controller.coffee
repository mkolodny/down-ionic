class FriendChatCtrl
  @$inject: ['$ionicScrollDelegate', '$meteor', '$mixpanel',
             '$scope', '$state', '$stateParams', 'Auth',
             'Friendship', 'User', 'Messages', '$rootScope']
  constructor: (@$ionicScrollDelegate, @$meteor, @$mixpanel,
                @$scope, @$state, @$stateParams, @Auth,
                @Friendship, @User, @Messages, @$rootScope) ->
    @friend = @$stateParams.friend

    @$scope.$on '$ionicView.beforeEnter', =>
      @$rootScope.hideTabBar = true

      @chatId = @Friendship.getChatId @friend.id

      # Bind reactive variables
      @messages = @$meteor.collection @getMessages, false

      # Watch for changes in newest message
      @watchNewestMessage()

    @$scope.$on '$ionicView.beforeLeave', =>
      @$rootScope.hideTabBar = false

    @$scope.$on '$ionicView.leave', =>
      # Remove angular-meteor bindings.
      @messages.stop()

  watchNewestMessage: =>
    # Mark messages as read as they come in
    #   and scroll to bottom
    @$scope.$watch =>
      newestMessage = @messages[@messages.length-1]
      if angular.isDefined newestMessage
        newestMessage._id
    , @handleNewMessage

  handleNewMessage: (newMessageId) =>
    if newMessageId is undefined
      return

    @Messages.readMessage newMessageId
    @scrollBottom()

  getMessages: =>
    @$meteor.getCollectionByName 'messages'
      .find
        chatId: @chatId
      ,
        sort:
          createdAt: 1
        transform: @transformMessage

  transformMessage: (message) =>
    message.creator = new @User message.creator

    if message.type is 'invite_action'
      # Normalize data for event and recommended
      #   event to simplify HTML
      if angular.isDefined message.meta.event
        message.eventData = message.meta.event
      else
        message.eventData = message.meta.recommendedEvent

    message

  isInviteAction: (message) ->
    message.type is 'invite_action'

  isTextMessage: (message) ->
    message.type is 'text'

  isMyMessage: (message) ->
    message.creator.id is "#{@Auth.user.id}"

  sendMessage: ->
    @Friendship.sendMessage @friend, @message
    @$mixpanel.track 'Send Message',
      'chat type': 'friend'
    @message = null

  scrollBottom: ->
    @$ionicScrollDelegate.$getByHandle 'friendChat'
      .scrollBottom true

  # viewEvent: (savedEvent) ->
  #   @$state.go 'friendChat.event',
  #     savedEvent: savedEvent
  #     commentsCount: @commentsCount[savedEvent.eventId]

module.exports = FriendChatCtrl
