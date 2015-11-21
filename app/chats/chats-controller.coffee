haversine = require 'haversine'

class ChatsCtrl
  @$inject: ['$ionicLoading', '$meteor', '$scope',
             '$state', 'Auth', 'Friendship', 'User']
  constructor: (@$ionicLoading, @$meteor, @$scope,
                @$state, @Auth, @Friendship, @User) ->
    # Init variables
    @users = {}

    # Set Meteor collections on controller
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'

    # Subscribe to all chats
    @$meteor.subscribe('allChats').then =>
      @allChatsLoaded = true
      # Subscribe to messages for all chats
      allChats = @Chats.find().fetch()
      chatIds = (chat._id for chat in allChats)
      @$meteor.subscribe 'messages', chatIds
      # Get users for chats
      @getChatUsers chatIds
    .then =>
      @messagesLoaded = true
      # messages subscription is ready
      @handleLoadedData()
      @watchNewMessages()
      @watchNewChats()

  handleLoadedData: ->
    if @allChatsLoaded and @messagesLoaded and @chatUsersLoaded
      @items = @buildItems()

  buildItems: ->

  watchNewChats: ->

  getChatUsers: (chatIds) ->
    userIds = (@Friendship.parseChatId(chatId) for chatId in chatIds)
    @User.query(userIds).$promise.then (users) =>
      for user in users
        @users[user.id] = user
      @chatUsersLoaded = true

  watchNewMessages: =>
    @messages = @$scope.$meteorCollection @Messages
    @$scope.$watch =>
      # TODO : Only compare newest
      (message for message in @messages)
    , (oldValue, newValue) =>
      if oldValue isnt newValue
        @handleLoadedData()
    , true

  getNewestMessage: (chatId) =>
    selector =
      _id: chatId
    options =
      transform: @transformMessage
    @NewestMessages.findOne(selector, options) or {}

  transformMessage: (message) =>
    # Show senders first name
    if message.type is 'text'
      firstName = message.creator.firstName
      message.text = "#{firstName}: #{message.text}"

    message

  wasRead: (message) =>
    # Get Chat object for message
    chat = @Chats.findOne {_id: message?.chatId}

    # Default to read to stop flicker
    if chat is undefined then return true

    members = chat.members or []
    lastRead = (member.lastRead for member in members \
        when "#{@Auth.user.id}" is member.userId)[0]
    lastRead >= message.createdAt

  # viewChat: (item) ->
  #   @$state.go 'event',
  #     invitation: item.invitation
  #     id: item.invitation.event.id


module.exports = ChatsCtrl
