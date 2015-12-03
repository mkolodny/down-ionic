class Messages
  @$inject: ['$rootScope', '$meteor', 'Auth']
  constructor: (@$rootScope, @$meteor, @Auth) ->
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'

  listen: ->
    # Subscribe to all chats
    @$meteor.subscribe('allChats').then =>
      @watchNewChats()

      # Subscribe to messages for chats
      allChats = @Chats.find().fetch()
      chatIds = (chat._id for chat in allChats)      
      @$meteor.subscribe 'messages', chatIds
    .then =>
      @watchNewMessages()
      @unreadCount = @getUnreadCount()

  watchNewChats: =>
    @chats = @$meteor.collection @Chats, false
    @chatIds = (chat._id for chat in @chats)
    @$rootScope.$watch =>
      @chats.length
    , (newValue, oldValue) =>
      if oldValue isnt newValue
        # Get diff in chats
        newChatIdsMap = {}
        newChatIds = []
        for chat in @chats
          newChatIds.push chat._id
          newChatIdsMap[chat._id] = true
        for chat in @chatIds
          delete newChatIdsMap[chat._id]
        for key, value of newChatIdsMap
          @$rootScope.$broadcast 'messages.newChat', key
        @chatIds = newChatIds
    , true

  watchNewMessages: =>
    options =
      sort:
        createdAt: -1
    @newestMessage = @$meteor.object @Messages, {}, false, options
    @$rootScope.$watch =>
      @newestMessage._id
    , (newValue, oldValue) =>
      if oldValue isnt newValue
        @unreadCount = @getUnreadCount()
        @$rootScope.$broadcast 'messages.newMessage', newValue
    , true

  getUnreadCount: ->
    chats = @Chats.find().fetch()
    totalCount = 0
    for chat in chats
      lastRead = (member.lastRead for member in chat.members \
        when "#{@Auth.user.id}" is member.userId)[0]
      selector =
        chatId: chat._id
        createdAt:
          $gt: lastRead
      totalCount += @Messages.find(selector).count()
    totalCount

  readMessage: (messageId) ->
    @$meteor.call 'readMessage', messageId
      .then =>
        @unreadCount = @getUnreadCount()




module.exports = Messages
