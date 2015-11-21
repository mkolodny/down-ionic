haversine = require 'haversine'

class ChatsCtrl
  @$inject: ['$cordovaDatePicker', '$ionicHistory', '$ionicLoading',
             '$ionicPlatform', '$ionicPopup', '$meteor', '$mixpanel', '$scope',
             '$state', '$timeout', 'Auth', 'Friendship', 'Invitation',
             'ngToast', 'User']
  constructor: (@$cordovaDatePicker, @$ionicHistory, @$ionicLoading,
                @$ionicPlatform, @$ionicPopup, @$meteor, @$mixpanel, @$scope,
                @$state, @$timeout, @Auth, @Friendship, @Invitation,
                @ngToast, @User) ->
    # Set Meteor collections on controller
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'

    # Subscribe to all chats for unread messages
    @$meteor.subscribe 'allChats'

    # Subscribe to chat latest messages
    @$meteor.subscribe('newestMessages').then =>
      @handleLoadedData()
      @watchNewMessages()

      @$meteor.subscribe 'allMessages'


  handleLoadedData: ->


  watchNewMessages: ->
    @Messages = @$scope.$meteorCollection @Messages
    @$scope.$watch =>
      # TODO : Only compare newest
      (message for message in @Messages)
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
