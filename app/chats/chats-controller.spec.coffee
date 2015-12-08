require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
require '../common/points/points-module'
require './chats-module'
ChatsCtrl = require './chats-controller'

describe 'chats controller', ->
  $httpBackend = null
  $meteor = null
  $q = null
  $state = null
  allChatsDeferred = null
  Auth = null
  chat23 = null
  chat24 = null
  ctrl = null
  chatsCollection = null
  chatIds = null
  earlier = null
  Friendship = null
  item = null
  messagesCollection = null
  messagesDeferred = null
  later = null
  Points = null
  scope = null
  User = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.chats')

  beforeEach angular.mock.module('rallytap.points')

  beforeEach angular.mock.module('ionic')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $httpBackend = $injector.get '$httpBackend'
    $meteor = $injector.get '$meteor'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    Event = $injector.get 'Event'
    Friendship = $injector.get 'Friendship'
    Points = $injector.get 'Points'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    earlier = new Date()
    later = new Date earlier.getTime()+1

    # Mock chats
    Auth.user =
      id: 2
    chat23 =
      _id: '2,3'
    chat24 =
      _id: '2,4'
    chats = [chat23, chat24]
    chatIds = [chat23._id, chat24._id]
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

    # For some reason, we're making requests to this URL.
    # TODO: Figure out why, and remove this.
    $httpBackend.expectGET 'app/chats/chats.html'
      .respond 200

    ctrl = $controller ChatsCtrl,
      $scope: scope
  )

  it 'should init the users object', ->
    expect(ctrl.users).toEqual {}

  it 'should init the items array', ->
    expect(ctrl.items).toEqual []

  it 'should set the Chats collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'chats'
    expect(ctrl.Chats).toBe chatsCollection

  it 'should set the current user on the controller', ->
    expect(ctrl.currentUser).toBe Auth.user

  it 'should subscribe to all the chats', ->
    expect($meteor.subscribe).toHaveBeenCalledWith 'allChats'

  it 'should set the points service on the controller', ->
    expect(ctrl.Points).toBe Points

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


  ##$ionicView.beforeEnter
  describe 'before the view enters', ->

    beforeEach ->
      spyOn ctrl, 'handleLoadedData'

      scope.$broadcast '$ionicView.beforeEnter'
      scope.$apply()

    it 'should handle the loaded data', ->
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
  describe 'building the items', ->
    newerMessage = null
    olderMessage = null
    user3 = null
    user4 = null
    items = null

    beforeEach ->
      user3 =
        name: 'Andrew'
      user4 =
        name: 'Bob'
      ctrl.users =
        '3': user3
        '4': user4
      newerMessage =
        createdAt: earlier
      olderMessage =
        createdAt: later
      spyOn(ctrl, 'getNewestMessage').and.callFake (chatId) ->
        if chatId is '2,3' then return newerMessage
        if chatId is '2,4' then return olderMessage

      items = ctrl.buildItems()

    it 'should transform the chats', ->
      selector = {}
      options =
        transform: ctrl.transformChat
      expect(ctrl.Chats.find).toHaveBeenCalledWith selector, options

    it 'should build the items', ->
      expect(items).toEqual [
        friend: user3
        chat: chat23
        newestMessage: newerMessage
      ,
        friend: user4
        chat: chat24
        newestMessage: olderMessage
      ]

  ##watchNewChats
  describe 'watching for new chats', ->

    beforeEach ->
      ctrl.watchNewChats()

    describe 'when a new chat comes in', ->
      chatId = null

      beforeEach ->
        spyOn ctrl, 'getChatUsers'
        chatId = 'asdfas'
        scope.$broadcast 'messages.newChat', chatId
        scope.$apply()

      it 'should get the chat users', ->
        expect(ctrl.getChatUsers).toHaveBeenCalledWith [chatId]


  ##getChatUsers
  describe 'getting users from chat ids', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(User, 'query').and.returnValue {$promise: deferred.promise}
      spyOn ctrl, 'handleLoadedData'

      ctrl.getChatUsers chatIds

    it 'should request the users', ->
      userIds = (Friendship.parseChatId(chatId) for chatId in chatIds).join ','
      expect(User.query).toHaveBeenCalledWith {ids: userIds}

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

      it 'should handle the loaded data', ->
        expect(ctrl.handleLoadedData).toHaveBeenCalled()


  ##watchNewMessages
  describe 'watching for new messages', ->
    newestMessage = null

    beforeEach ->
      spyOn ctrl, 'handleLoadedData'
      ctrl.watchNewMessages()

    describe 'when a new message is posted', ->

      beforeEach ->
        scope.$broadcast 'messages.newMessage'
        scope.$apply()

      it 'should handle the loaded data', ->
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
        ctrl.Messages =
          findOne: jasmine.createSpy('Messages.findOne') \
            .and.returnValue newestMessage
        result = ctrl.getNewestMessage chatId

      it 'should return the newest message', ->
        expect(result).toBe newestMessage

      it 'should query, sort and transform the message', ->
        selector =
          chatId: chatId
        options =
          transform: ctrl.transformMessage
          sort:
            createdAt: -1
        expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector, options


    describe 'when no newest message is found', ->
      newestMessage = null
      result = null

      beforeEach ->
        ctrl.Messages =
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


  ##transformChat
  describe 'transforming a chat', ->
    fourteenHours = null
    sixHours = null
    result = null
    chat = null

    beforeEach ->
      jasmine.clock().install()
      date = new Date 1438014089235
      jasmine.clock().mockDate date
      now = new Date().getTime()

      sixHours = 1000 * 60 * 60 * 6
      chat =
        _id: 'asdfasdf'
        expiresAt: new Date(now + sixHours)
        createdAt: new Date(now - sixHours)

      result = ctrl.transformChat angular.copy(chat)

    afterEach ->
      jasmine.clock().uninstall()

    it 'should set the percent remaining', ->
      chat.percentRemaining = 50
      expect(result).toEqual chat


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
  describe 'viewing a chat', ->
    friend = null

    beforeEach ->
      spyOn $state, 'go'
      friend =
        id: 4
      item =
        friend: friend
      ctrl.viewChat item

    it 'should go to the friend chat', ->
      expect($state.go).toHaveBeenCalledWith 'friendChat',
        friend: friend
        id: friend.id


