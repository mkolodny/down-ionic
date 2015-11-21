require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
require './chats-module'
ChatsCtrl = require './chats-controller'

fdescribe 'chats controller', ->
  $meteor = null
  $q = null
  $state = null
  allChatsDeferred = null
  Auth = null
  chat1 = null
  chat2 = null
  ctrl = null
  chatsCollection = null
  chatIds = null
  earlier = null
  Friendship = null
  item = null
  messagesCollection = null
  messagesDeferred = null
  later = null
  scope = null
  User = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.chats')

  beforeEach angular.mock.module('ionic')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $meteor = $injector.get '$meteor'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    Event = $injector.get 'Event'
    Friendship = $injector.get 'Friendship'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    earlier = new Date()
    later = new Date earlier.getTime()+1


    # Mock chats
    Auth.user =
      id: 2
    chat1 =
      _id: '2,3'
    chat2 =
      _id: '2,4'
    chats = [chat1, chat2]
    chatIds = [chat1._id, chat2._id]
    fetch = jasmine.createSpy('find.fetch').and.returnValue chats
    chatsCollection =
      find: jasmine.createSpy('Chats.find').and.returnValue {fetch: fetch}
    messagesCollection = 'messagesCollection'
    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'messages' then return messagesCollection
      if collectionName is 'chats' then return chatsCollection

    allChatsDeferred = $q.defer()
    messagesDeferred = $q.defer()
    $meteor.subscribe.and.callFake (subscriptionName)->
      if subscriptionName is 'allChats' then return allChatsDeferred.promise
      if subscriptionName is 'messages' then return messagesDeferred.promise

    ctrl = $controller ChatsCtrl,
      $scope: scope
      Auth: Auth
  )
  
  it 'should init the users object', ->
    expect(ctrl.users).toEqual {}

  it 'should set the Chats collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'chats'
    expect(ctrl.Chats).toBe chatsCollection

  it 'should subscribe to all the chats', ->
    expect($meteor.subscribe).toHaveBeenCalledWith 'allChats'

  describe 'when the allChats subscription is ready', ->

    beforeEach ->
      spyOn ctrl, 'handleLoadedData'
      spyOn ctrl, 'watchNewMessages'
      spyOn ctrl, 'watchNewChats'
      spyOn ctrl, 'getChatUsers'

      allChatsDeferred.resolve()
      scope.$apply()

    it 'should set the all chats loaded flag', ->
      expect(ctrl.allChatsLoaded).toBe true

    it 'should subscribe to messages for all of the chats', ->
      expect($meteor.subscribe).toHaveBeenCalledWith 'messages', chatIds

    it 'should get the users for each chat', ->
      expect(ctrl.getChatUsers).toHaveBeenCalledWith chatIds

    describe 'when messages subscription is ready', ->

      beforeEach ->
        messagesDeferred.resolve()
        scope.$apply()

      it 'should set the messages loaded flag', ->
        expect(ctrl.messagesLoaded).toBe true

      it 'should watch for new messages', ->
        expect(ctrl.watchNewMessages).toHaveBeenCalled()

      it 'should watch for new chats', ->
        expect(ctrl.watchNewChats).toHaveBeenCalled()

      it 'should handleLoadedData', ->
        expect(ctrl.handleLoadedData).toHaveBeenCalled()


  ##handleLoadedData
  describe 'handling loaded data', ->

    describe 'when all data is loaded', ->

      beforeEach ->
        ctrl.allChatsLoaded = true
        ctrl.messagesLoaded = true
        ctrl.chatUsersLoaded = true

        spyOn(ctrl, 'buildItems').and.returnValue []

        ctrl.handleLoadedData()

      it 'should build the items and set them on the controller', ->
        expect(ctrl.items).toEqual []


  ##buildItems

  ##watchNewChats
  

  ##getChatUsers
  describe 'getting users from chat ids', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(User, 'query').and.returnValue {$promise: deferred.promise}

      ctrl.getChatUsers chatIds

    it 'should request the users', ->
      userIds = (Friendship.parseChatId(chatId) for chatId in chatIds)
      expect(User.query).toHaveBeenCalledWith userIds

    describe 'when the users are returned successfully', ->
      user1 = null
      user2 = null

      beforeEach ->
        user1 =
          id: 1
        user2 = 
          id: 2
        users = [user1, user2]

        deferred.resolve users
        scope.$apply()

      it 'should set the users object on the controller', ->
        usersObject =
          1: user1
          2: user2
        expect(ctrl.users).toEqual usersObject

      it 'should set the chat users loaded flag', ->
        expect(ctrl.chatUsersLoaded).toBe true


  ##watchNewMessages
  describe 'watching for new messages', ->

    beforeEach ->
      scope.$meteorCollection = jasmine.createSpy('scope.$meteorCollection') \
        .and.returnValue []

      ctrl.watchNewMessages()

    it 'should bind the newest messages to the controller', ->
      expect(scope.$meteorCollection).toHaveBeenCalledWith ctrl.NewestMessages
      expect(ctrl.newestMessages).toEqual []

    describe 'when a new message comes in', ->

      beforeEach ->
        spyOn ctrl, 'handleLoadedData'
        ctrl.newestMessages = [1]
        scope.$apply()
        ctrl.newestMessages = [2]
        scope.$apply()

      it 'should re-build the items', ->
        expect(ctrl.handleLoadedData).toHaveBeenCalled()


  ##getNewestMessage
  describe 'getting the newest message', ->

    describe 'when there is a newest message', ->
      chatId = null
      newestMessage = null
      result = null

      beforeEach ->
        chatId = "3"
        newestMessage = 'newestMessage'
        ctrl.NewestMessages =
          findOne: jasmine.createSpy('NewestMessages.findOne') \
            .and.returnValue newestMessage
        result = ctrl.getNewestMessage chatId

      it 'should return the newest message', ->
        expect(result).toBe newestMessage

      it 'should query, sort and transform the message', ->
        selector =
          _id: chatId
        options =
          transform: ctrl.transformMessage
        expect(ctrl.NewestMessages.findOne).toHaveBeenCalledWith selector, options


    describe 'when no newest message is found', ->
      newestMessage = null
      result = null

      beforeEach ->
        ctrl.NewestMessages =
          findOne: jasmine.createSpy('NewestMessages.findOne') \
            .and.returnValue undefined
        result = ctrl.getNewestMessage '1234'

      it 'should return a blank object', ->
        expect(result).toEqual {}


  ##transformMessage
  describe 'transforming a message', ->

    describe 'when the message is of type text', ->
      message = null
      result = null

      beforeEach ->
        message =
          type: 'text'
          text: 'Hi Guys!'
          creator:
            firstName: 'Jimbo'

        result = ctrl.transformMessage angular.copy(message)

      it 'should update the message text', ->
        expectedText = "#{message.creator.firstName}: #{message.text}"
        expect(result.text).toEqual expectedText


  ##wasRead
  describe 'checking if a message was read', ->

    describe 'when the message data has\'t loaded yet', ->
      result = null

      beforeEach ->
        ctrl.Chats =
          findOne: jasmine.createSpy('Chats.findOne').and.returnValue undefined

        result = ctrl.wasRead undefined

      it 'should default to true', ->
        expect(result).toBe true


    describe 'when the chat data has\'t loaded yet', ->
      result = null

      beforeEach ->
        ctrl.Chats =
          findOne: jasmine.createSpy('Chats.findOne').and.returnValue undefined

        result = ctrl.wasRead undefined

      it 'should default to true', ->
        expect(result).toBe true


    describe 'when a message has been read', ->
      message = null
      result = null

      beforeEach ->
        Auth.user =
          id: 1
        message =
          createdAt: new Date 10
        chat =
          members: [
            userId: "1",
            lastRead: new Date 1000
          ]
        ctrl.Chats =
          findOne: jasmine.createSpy('Chats.findOne').and.returnValue chat

        result = ctrl.wasRead message

      it 'should return true', ->
        expect(result).toBe true


    describe 'when a message has not been read', ->
      message = null
      result = null

      beforeEach ->
        Auth.user =
          id: 1
        message =
          createdAt: new Date 1000
        chat =
          members: [
            userId: "1",
            lastRead: new Date 10
          ]
        ctrl.Chats =
          findOne: jasmine.createSpy('Chats.findOne').and.returnValue chat

        result = ctrl.wasRead message

      it 'should return false', ->
        expect(result).toBe false

  ##viewChat
  xdescribe 'viewing a chat', ->
  #   invitation = null

  #   beforeEach ->
  #     spyOn $state, 'go'
  #     invitation =
  #       event:
  #         id: 1
  #     item =
  #       invitation: invitation
  #     ctrl.viewEventChat item

  #   it 'should go to the event chat', ->
  #     expect($state.go).toHaveBeenCalledWith 'event',
  #       invitation: invitation
  #       id: invitation.event.id


