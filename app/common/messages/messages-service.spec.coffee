require '../../ionic/ionic.js'
require 'angular'
require 'angular-mocks'
require '../auth/auth-module'
require '../meteor/meteor-mocks'
require './messages-module'

describe 'Messages service', ->
  $q = null
  $meteor = null
  $rootScope = null
  Auth = null
  scope = null
  Messages = null
  messagesCollection = null
  chatsCollection = null
  chat23 = null
  chats = null
  chatIds = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.messages')

  beforeEach inject(($injector) ->
    $q = $injector.get '$q'
    $meteor = $injector.get '$meteor'
    $rootScope = $injector.get '$rootScope'
    Auth = $injector.get 'Auth'
    scope = $rootScope.$new()

    # Mock chats
    Auth.user =
      id: 2
    chat23 =
      _id: '2,3'
      members: [
        userId: '2'
        lastRead: new Date()
      ]
    chats = [chat23]
    chatIds = [chat23._id]
    fetch = jasmine.createSpy('find.fetch').and.returnValue chats
    chatsCollection =
      find: jasmine.createSpy('Chats.find').and.returnValue {fetch: fetch}

    messagesCollection =
      find: jasmine.createSpy('Messages.find').and.returnValue
        fetch: jasmine.createSpy('Messages.find.fetch')
        count: jasmine.createSpy('Messages.find.count').and.returnValue 1

    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'messages' then return messagesCollection
      if collectionName is 'chats' then return chatsCollection

    Messages = $injector.get 'Messages'
  )

  it 'should set the messages collection on the service', ->
    expect(Messages.Messages).toBe messagesCollection
  
  it 'should set the chats collection on the service', ->
    expect(Messages.Chats).toBe chatsCollection

  ##listen
  describe 'listening for new data', ->
    allChatsDeferred = null
    messagesDeferred = null

    beforeEach ->
      spyOn Messages, 'watchNewChats'
      spyOn Messages, 'watchNewMessages'

      allChatsDeferred = $q.defer()
      messagesDeferred = $q.defer()
      $meteor.subscribe.and.callFake (subscriptionName)->
        if subscriptionName is 'allChats' then return allChatsDeferred.promise
        if subscriptionName is 'messages' then return messagesDeferred.promise

      Messages.listen()

    it 'should subscribe to all the chats', ->
      expect($meteor.subscribe).toHaveBeenCalledWith 'allChats'

    describe 'when the allChats subscription is ready', ->

      beforeEach ->
        allChatsDeferred.resolve()
        scope.$apply()

      it 'should watch for new chats', ->
        expect(Messages.watchNewChats).toHaveBeenCalled()

      it 'should subscribe to messages for all of the chats', ->
        expect($meteor.subscribe).toHaveBeenCalledWith 'messages', chatIds

      describe 'when messages subscription is ready', ->
        unreadCount = null

        beforeEach ->
          unreadCount = 1
          spyOn(Messages, 'getUnreadCount').and.returnValue unreadCount

          messagesDeferred.resolve()
          scope.$apply()

        it 'should watch for new messages', ->
          expect(Messages.watchNewMessages).toHaveBeenCalled()

        it 'should set the unread count on the service', ->
          expect(Messages.unreadCount).toBe unreadCount


  ##watchNewChats
  describe 'watching for new chats', ->
    allChats = null

    beforeEach ->
      $meteor.collection.and.returnValue chats
      spyOn($rootScope, '$broadcast').and.callThrough()

      Messages.watchNewChats()

    it 'should bind the chats cursor to the controller', ->
      expect(Messages.chats).toBe chats

    describe 'when a new chat comes in', ->
      newChat = null

      beforeEach ->
        newChat =
          _id: 'daskfjna'
        Messages.chats.push newChat
        $rootScope.$apply()
        Messages.chats.push newChat
        $rootScope.$apply()

      it 'should broadcast a new chat event', ->
        expect($rootScope.$broadcast).toHaveBeenCalledWith 'messages.newChat', newChat._id
  

  ##watchNewMessages
  describe 'watching for new messages', ->
    newestMessage = null
    unreadCount = null

    beforeEach ->
      newestMessage =
        _id: 'asdflkjn;anoi'
      $meteor.object.and.returnValue newestMessage

      spyOn($rootScope, '$broadcast').and.callThrough()
      unreadCount = 1
      spyOn(Messages, 'getUnreadCount').and.returnValue unreadCount

      Messages.watchNewMessages()

    it 'should bind the newest message to the controller', ->
      options =
        sort:
          createdAt: -1
      expect($meteor.object).toHaveBeenCalledWith Messages.Messages, {}, false, options
      expect(Messages.newestMessage).toEqual newestMessage

    describe 'when a new message comes in', ->

      beforeEach ->
        Messages.newestMessage =
          _id: 'alkjsdfn'
        $rootScope.$apply()
        Messages.newestMessage =
          _id: 'aksdjfierfq'
        $rootScope.$apply()

      it 'should set the unread count on the controller', ->
        expect(Messages.unreadCount).toBe unreadCount

      it 'should broadcast a new message event', ->
        expect($rootScope.$broadcast).toHaveBeenCalledWith 'messages.newMessage', Messages.newestMessage._id


  ##getUnreadCount
  describe 'getting the number of unread messages', ->
    response = null

    beforeEach ->
      response = Messages.getUnreadCount()

    it 'should return the number of unread messages', ->
      expect(response).toBe 1


  ##readMessage
  describe 'marking a message as read', ->
    unreadCount = null
    messageId = null
    defered = null

    beforeEach ->
      unreadCount = 1
      spyOn(Messages, 'getUnreadCount').and.returnValue unreadCount

      defered = $q.defer()
      $meteor.call.and.returnValue defered.promise

      messageId = 'asdkfjnasd'
      Messages.readMessage messageId

    it 'should call the read message method', ->
      expect($meteor.call).toHaveBeenCalledWith 'readMessage', messageId

    describe 'when the method returns', ->

      beforeEach ->
        defered.resolve()
        $rootScope.$apply()

      it 'should get the new unread count', ->
        expect(Messages.unreadCount).toBe unreadCount


