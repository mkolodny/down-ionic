require 'angular'
require 'angular-mocks'
require '../common/auth/auth-module'
require '../common/mixpanel/mixpanel-module'
require '../common/meteor/meteor-mocks'
require '../common/messages/messages-module'
FriendChatCtrl = require './friend-chat-controller'

describe 'friend chat controller', ->
  $ionicScrollDelegate = null
  $meteor = null
  $mixpanel = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  friend = null
  Friendship = null
  Invitation = null
  Messages = null
  scope = null
  User = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.messages')

  beforeEach angular.mock.module('ionic')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicScrollDelegate = $injector.get '$ionicScrollDelegate'
    $meteor = $injector.get '$meteor'
    $mixpanel = $injector.get '$mixpanel'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $stateParams = angular.copy $injector.get('$stateParams')
    Auth = $injector.get 'Auth'
    Friendship = $injector.get 'Friendship'
    Messages = $injector.get 'Messages'
    scope = $injector.get '$rootScope'
    User = $injector.get 'User'

    Auth.user =
      id: 2
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535
    friend =
      id: 1
      email: 'benihana@gmail.com'
      name: 'Benny Hana'
      firstName: 'Benny'
      lastName: 'Hana'
      username: 'benihana'
      imageUrl: 'https://facebook.com/profile-pics/benihana'
      location:
        lat: 40.7265834
        long: -73.9821535
    $stateParams.friend = friend

    ctrl = $controller FriendChatCtrl,
      $scope: scope
      $stateParams: $stateParams
      Auth: Auth
  )

  it 'should set the friend on the controller', ->
    expect(ctrl.friend).toBe friend

  ##$ionicView.beforeEnter
  describe 'once the view loads', ->
    chatId = null
    message = null
    messages = null

    beforeEach ->
      chatId = '1,2'
      spyOn(Friendship, 'getChatId').and.returnValue chatId
      message =
        _id: 1
        creator: new User Auth.user
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        chatId: chatId
        type: 'text'
      messages = [message]
      $meteor.collection.and.returnValue messages
      spyOn ctrl, 'watchNewestMessage'

      scope.$emit '$ionicView.beforeEnter'
      scope.$apply()

    it 'should get the chat id', ->
      expect(Friendship.getChatId).toHaveBeenCalledWith ctrl.friend.id

    it 'should set the chat id on the controller', ->
      expect(ctrl.chatId).toBe chatId

    it 'should watch the newestMessage', ->
      expect(ctrl.watchNewestMessage).toHaveBeenCalled()

    it 'should bind the messages to the controller', ->
      expect($meteor.collection).toHaveBeenCalledWith ctrl.getMessages, false
      expect(ctrl.messages).toBe messages


  ##$ionicView.leave
  describe 'when leaving the view', ->

    beforeEach ->
      ctrl.messages =
        stop: jasmine.createSpy 'messages.stop'

      scope.$broadcast '$ionicView.leave'
      scope.$apply()

    it 'should stop the angular-meteor bindings', ->
      expect(ctrl.messages.stop).toHaveBeenCalled()


  ##watchNewestMessage
  describe 'watching new messages coming in', ->

    describe 'when new messages get posted', ->

      beforeEach ->
        spyOn ctrl, 'handleNewMessage'

        message =
          _id: 'asdfs'
          creator: new User Auth.user
          createdAt: new Date()
          text: 'I\'m in love with a robot.'
          type: 'text'

        ctrl.watchNewestMessage()

        # Trigger watch
        ctrl.messages = [message]
        scope.$apply()


      it 'should handle the new message', ->
        expect(ctrl.handleNewMessage).toHaveBeenCalled()


  ##handleNewMessage
  describe 'handling a new message', ->
    newMessageId = null
    message = null

    beforeEach ->
      newMessageId = '2341sadfas'
      message =
        _id: 'jnwljnr'
        creator: new User Auth.user
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        chatId: '1,2'
        type: 'text'
      ctrl.messages = [message]

      message2 = angular.extend {}, message,
        _id: newMessageId
        type: 'invite_action'
      ctrl.messages.push message2

      spyOn ctrl, 'scrollBottom'
      spyOn Messages, 'readMessage'

      ctrl.handleNewMessage newMessageId

    it 'should mark the message as read', ->
      expect(Messages.readMessage).toHaveBeenCalledWith newMessageId

    it 'should scroll to the bottom', ->
      expect(ctrl.scrollBottom).toHaveBeenCalled()


  ##getMessages
  describe 'getting messages', ->
    cursor = null
    messages = null
    messagesCollection = null

    beforeEach ->
      messagesCollection =
        find: jasmine.createSpy('Messages.find').and.returnValue cursor
      $meteor.getCollectionByName.and.callFake (collectionName) ->
        if collectionName is 'messages' then return messagesCollection
      ctrl.chatId = '1,2'
      cursor = 'messagesCursor'
      messages = ctrl.getMessages()

    it 'should query, sort and transform messages', ->
      selector =
        chatId: ctrl.chatId
      options =
        sort:
          createdAt: 1
        transform: ctrl.transformMessage
      expect(messagesCollection.find).toHaveBeenCalledWith selector, options

    it 'should return a messages reactive cursor', ->
      expect(messages).toBe cursor


  ##transformMessage
  describe 'transforming messages', ->
    message = null
    transformedMessage = null

    beforeEach ->
      message =
        creator: {}
      transformedMessage = ctrl.transformMessage message

    it 'should create a new User object with the message.creator', ->
      messageCopy = angular.copy message
      messageCopy.creator = new User messageCopy.creator
      expect(transformedMessage).toEqual messageCopy
  

  ##isInviteAction
  describe 'checking whether a message is an invite action message', ->
    message = null

    beforeEach ->
      message =
        _id: 1
        creator: new User {id: 2}
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        chatId: '1,2'
        type: 'text'

    describe 'when it is an invite action', ->

      beforeEach ->
        message.type = 'invite_action'

      it 'should return true', ->
        expect(ctrl.isInviteAction message).toBe true


    describe 'when it isn\'t an invite action', ->

      beforeEach ->
        message.type = 'text'

      it 'should return false', ->
        expect(ctrl.isInviteAction message).toBe false


  ##isTextMessage
  describe 'checking whether a message is a text message', ->
    message = null

    beforeEach ->
      message =
        _id: 1
        creator: new User {id: 2}
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        groupId: '1,2'

    describe 'when it is a text message', ->

      beforeEach ->
        message.type = 'text'

      it 'should return true', ->
        expect(ctrl.isTextMessage message).toBe true


    describe 'when it isn\'t a text message', ->

      beforeEach ->
        message.type = 'invite_action'

      it 'should return false', ->
        expect(ctrl.isTextMessage message).toBe false


  ##isMyMessage
  describe 'checking whether a message is the current user\'s message', ->
    message = null

    beforeEach ->
      creator =
        id: 2
        name: 'Guido van Rossum'
        imageUrl: 'http://facebook.com/profile-pics/vrawesome'
      message =
        _id: 1
        creator: new User creator
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        groupId: '1,2'
        type: 'text'

    describe 'when it is', ->

      beforeEach ->
        message.creator.id = "#{Auth.user.id}" # Meteor likes strings

      it 'should return true', ->
        expect(ctrl.isMyMessage message).toBe true


    describe 'when it isn\'t', ->

      beforeEach ->
        message.creator.id = "#{Auth.user.id + 1}" # Meteor likes strings

      it 'should return false', ->
        expect(ctrl.isMyMessage message).toBe false


  ##sendMessage
  describe 'sending a message', ->
    message = null

    beforeEach ->
      message = 'this is gonna be dope!'
      ctrl.message = message
      spyOn Friendship, 'sendMessage'
      spyOn $mixpanel, 'track'

      ctrl.sendMessage()

    it 'should send the message', ->
      expect(Friendship.sendMessage).toHaveBeenCalledWith ctrl.friend, message

    it 'should track Sent message in Mixpanel', ->
      expect($mixpanel.track).toHaveBeenCalledWith 'Send Message',
        'chat type': 'friend'

    it 'should clear the message', ->
      expect(ctrl.message).toBeNull()


  ##scrollBottom
  describe 'scrolling to the bottom', ->
    scrollHandle = null

    describe 'when scrolling bottom is enabled', ->

      beforeEach ->
        scrollHandle =
          scrollBottom: jasmine.createSpy 'scrollHandle.scrollBottom'
        spyOn($ionicScrollDelegate, '$getByHandle').and.returnValue scrollHandle

        ctrl.scrollBottom()

      it 'should scroll to the bottom', ->
        expect(scrollHandle.scrollBottom).toHaveBeenCalledWith true
