require '../ionic/ionic.js' # for ionic module
require 'angular'
require 'angular-animate' # for ionic module
require 'angular-mocks'
require 'angular-sanitize' # for ionic module
require 'angular-ui-router'
require '../ionic/ionic-angular.js' # for ionic module
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
require '../common/mixpanel/mixpanel-module'
require './events-module'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $compile = null
  $httpBackend = null
  $ionicHistory = null
  $ionicPlatform = null
  $ionicPopup = null
  $meteor = null
  $mixpanel = null
  $q = null
  $state = null
  $timeout = null
  $window = null
  Auth = null
  ctrl = null
  chatsCollection = null
  deferredGetInvitations = null
  deferredTemplate = null
  earlier = null
  Event = null
  Friendship = null
  item = null
  invitation = null
  later = null
  Invitation = null
  newestMessagesCollection = null
  newestMessagesDeferred = null
  ngToast = null
  scope = null
  User = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.events')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngToast')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $controller = $injector.get '$controller'
    $httpBackend = $injector.get '$httpBackend'
    $ionicHistory = $injector.get '$ionicHistory'
    $ionicPlatform = $injector.get '$ionicPlatform'
    $ionicPopup = $injector.get '$ionicPopup'
    $meteor = $injector.get '$meteor'
    $mixpanel = $injector.get '$mixpanel'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $timeout = $injector.get '$timeout'
    $window = $injector.get '$window'
    Auth = $injector.get 'Auth'
    Event = $injector.get 'Event'
    Friendship = $injector.get 'Friendship'
    Invitation = $injector.get 'Invitation'
    ngToast = $injector.get 'ngToast'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    earlier = new Date()
    later = new Date earlier.getTime()+1
    invitation = new Invitation
      id: 1
      event: new Event
        id: 1
        title: 'bars?!?!!?'
        creator: 2
        canceled: false
        datetime: new Date()
        createdAt: new Date()
        updatedAt: earlier
        place:
          name: 'B Bar & Grill'
          lat: 40.7270718
          long: -73.9919324
      fromUser: new User
        id: 3
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pics/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535
      toUser: 4
      response: Invitation.noResponse
      open: false
      muted: false
      lastViewed: later
      createdAt: new Date()
      updatedAt: new Date()
    item =
      isDivider: false
      invitation: invitation
      id: invitation.id

    # This is necessary because for some reason ionic is requesting this file
    # when the promise gets resolved.
    # TODO: Figure out why, and remove this.
    $httpBackend.whenGET 'app/events/events.html'
      .respond ''

    deferredGetInvitations = $q.defer()
    spyOn(Invitation, 'getMyInvitations').and.returnValue \
        deferredGetInvitations.promise
    spyOn $ionicPlatform, 'on'

    newestMessagesCollection = 'newestMessagesCollection'
    chatsCollection = 'chatsCollection'
    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'newestMessages' then return newestMessagesCollection
      if collectionName is 'chats' then return chatsCollection

    newestMessagesDeferred = $q.defer()
    $meteor.subscribe.and.callFake (subscriptionName) =>
      if subscriptionName is 'newestMessages'
        return newestMessagesDeferred.promise

    ctrl = $controller EventsCtrl,
      $scope: scope
      Auth: Auth
  )

  it 'should set the Chats collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'chats'
    expect(ctrl.Chats).toBe chatsCollection

  it 'should subscribe to the newestMessages', ->
    expect($meteor.subscribe).toHaveBeenCalledWith 'newestMessages'

  it 'should subscribe to all the chats', ->
    expect($meteor.subscribe).toHaveBeenCalledWith 'allChats'

  describe 'when the newestMessages subscription is ready', ->

    beforeEach ->
      spyOn ctrl, 'handleLoadedData'
      spyOn ctrl, 'watchNewMessages'

      newestMessagesDeferred.resolve()
      scope.$apply()

    it 'should subscribe to all messages', ->
      expect($meteor.subscribe).toHaveBeenCalledWith 'allMessages'

    it 'should watch for new messages', ->
      expect(ctrl.watchNewMessages).toHaveBeenCalled()

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


