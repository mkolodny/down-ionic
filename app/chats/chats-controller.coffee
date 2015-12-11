haversine = require 'haversine'

class ChatsCtrl
  @$inject: ['$ionicLoading', '$meteor', '$scope',
             '$state', 'Auth', 'Friendship', 'Points', 'User']
  constructor: (@$ionicLoading, @$meteor, @$scope,
                @$state, @Auth, @Friendship, @Points, @User) ->
    # Init variables
    @users = {}
    @items = []

    @$scope.$on '$ionicView.loaded', =>
      @currentUser = @Auth.user

      # Set Meteor collections on controller
      @Messages = @$meteor.getCollectionByName 'messages'
      @Chats = @$meteor.getCollectionByName 'chats'

      @$ionicLoading.show()

      # Subscribe to all chats
      @$scope.$meteorSubscribe 'allChats'
        .then =>
          @allChatsLoaded = true

          allChats = @Chats.find().fetch()
          chatIds = (chat._id for chat in allChats)
          @getChatUsers chatIds
          @$scope.$meteorSubscribe 'messages', chatIds
        .then =>
          @messagesLoaded = true
          # messages subscription is ready
          @$ionicLoading.hide()
          @handleLoadedData()
          @watchNewMessages()
          @watchNewChats()

    @$scope.$on '$ionicView.beforeEnter', =>
      @handleLoadedData()

  handleLoadedData: ->
    if @allChatsLoaded and @messagesLoaded and @chatUsersLoaded
      @items = @buildItems()
      @itemsLoaded = true

  buildItems: ->
    items = []

    selector = {}
    options =
      transform: @transformChat
    chats = @Chats.find(selector, options).fetch()
    for chat in chats
      friendId = @Friendship.parseChatId chat._id
      items.push
        friend: @users[friendId]
        chat: chat
        newestMessage: @getNewestMessage chat._id

    # Sort by newestMessage.createdAt
    items.sort (a, b) ->
      a.newestMessage.createdAt < b.newestMessage.createdAt

    items

  watchNewChats: ->
    @$scope.$on 'messages.newChat', (event, chatId) =>
      @getChatUsers [chatId]

  getChatUsers: (chatIds) ->
    # TODO: Only grab users once
    userIds = (@Friendship.parseChatId(chatId) for chatId in chatIds).join ','

    # Don't try to get users if there are no chats
    if userIds.length is 0
      @chatUsersLoaded = true

    @User.query {ids: userIds}
      .$promise.then (users) =>
        for user in users
          @users[user.id] = user
        @chatUsersLoaded = true
        @handleLoadedData()

  watchNewMessages: =>
    @$scope.$on 'messages.newMessage', =>
      @handleLoadedData()

  getNewestMessage: (chatId) =>
    selector =
      chatId: chatId
    options =
      transform: @transformMessage
      sort:
        createdAt: -1
    @Messages.findOne(selector, options) or {}

  transformMessage: (message) =>
    # Show senders first name
    if message.type is 'text'
      firstName = message.creator.firstName
      message.text = "#{firstName}: #{message.text}"

    message

  transformChat: (chat) =>
    now = new Date().getTime()
    timeRemaining = chat.expiresAt?.getTime() - now
    totalTime = chat.expiresAt?.getTime() - chat.createdAt?.getTime()
    chat.percentRemaining = Math.round (timeRemaining / totalTime) * 100
    chat

  wasRead: (message) =>
    # Get Chat object for message
    chat = @Chats.findOne {_id: message?.chatId}
    # Default to read to stop flicker
    if chat is undefined then return true

    members = chat.members or []
    lastRead = (member.lastRead for member in members \
        when "#{@Auth.user.id}" is member.userId)[0]
    lastRead >= message.createdAt

  viewChat: (item) ->
    @$state.go 'friendChat',
      friend: item.friend
      id: item.friend.id

module.exports = ChatsCtrl
