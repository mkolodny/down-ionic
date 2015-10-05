require '../ionic/ionic.js' # for ionic module
require 'angular'
require 'angular-animate' # for ionic module
require 'angular-mocks'
require 'angular-sanitize' # for ionic module
require 'angular-ui-router'
require '../ionic/ionic-angular.js' # for ionic module
require 'ng-cordova'
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
require './events-module'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $compile = null
  $cordovaDatePicker = null
  $httpBackend = null
  $ionicHistory = null
  $ionicModal = null
  $ionicPlatform = null
  $meteor = null
  $q = null
  $state = null
  $timeout = null
  $window = null
  Auth = null
  ctrl = null
  deferredGetInvitations = null
  deferredTemplate = null
  earlier = null
  Event = null
  chatsCollection = null
  item = null
  invitation = null
  later = null
  Invitation = null
  messagesCollection = null
  ngToast = null
  scope = null
  User = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.events')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngCordova')

  beforeEach angular.mock.module('ngToast')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $controller = $injector.get '$controller'
    $cordovaDatePicker = $injector.get '$cordovaDatePicker'
    $httpBackend = $injector.get '$httpBackend'
    $ionicHistory = $injector.get '$ionicHistory'
    $ionicModal = $injector.get '$ionicModal'
    $ionicPlatform = $injector.get '$ionicPlatform'
    $meteor = $injector.get '$meteor'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $timeout = $injector.get '$timeout'
    $window = $injector.get '$window'
    Auth = angular.copy $injector.get 'Auth'
    Event = $injector.get 'Event'
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

    deferredTemplate = $q.defer()
    spyOn($ionicModal, 'fromTemplateUrl').and.returnValue deferredTemplate.promise
    spyOn $ionicPlatform, 'on'

    messagesCollection = 'messagesCollection'
    chatsCollection = 'chatsCollection'
    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'messages' then return messagesCollection
      if collectionName is 'chats' then return chatsCollection

    ctrl = $controller EventsCtrl,
      $scope: scope
      Auth: Auth
  )

  it 'should init a new event', ->
    expect(ctrl.newEvent).toEqual {}

  it 'should init a set place modal', ->
    templateUrl = 'app/set-place/set-place.html'
    expect($ionicModal.fromTemplateUrl).toHaveBeenCalledWith templateUrl,
      scope: scope
      animation: 'slide-in-up'

  it 'should set a loading flag', ->
    expect(ctrl.isLoading).toBe true

  it 'should listen for when the user comes back to the app', ->
    expect($ionicPlatform.on).toHaveBeenCalledWith 'resume', ctrl.manualRefresh

  it 'should set the messages collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'messages'
    expect(ctrl.Messages).toBe messagesCollection

  it 'should set the events collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'chats'
    expect(ctrl.Chats).toBe chatsCollection

  describe 'when the events request returns', ->
    refreshComplete = null

    beforeEach ->
      # Listen to the refresh complete event to check whether we've broadcasted
      # the event.
      refreshComplete = false
      scope.$on 'scroll.refreshComplete', ->
        refreshComplete = true

    describe 'successfully', ->
      items = null
      percentRemaining = null
      response = null

      beforeEach ->
        items = []
        spyOn(ctrl, 'buildItems').and.returnValue items
        spyOn ctrl, 'eventsMessagesSubscribe'
        percentRemaining = 16
        spyOn(invitation.event, 'getPercentRemaining').and.returnValue \
            percentRemaining

        response = [invitation]
        deferredGetInvitations.resolve response
        scope.$apply()

      it 'should save the invitations on the controller', ->
        invitations = {"#{invitation.id}": invitation}
        expect(ctrl.invitations).toEqual invitations

      it 'should save the items list on the controller', ->
        invitations = {}
        for invitation in response
          invitations[invitation.id] = invitation
        expect(ctrl.buildItems).toHaveBeenCalledWith invitations

      it 'should subscribe to messages for each event', ->
        events = [invitation.event]
        expect(ctrl.eventsMessagesSubscribe).toHaveBeenCalledWith events

      it 'should clear a loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should set the percent remaining on the event', ->
        expect(invitation.event.percentRemaining).toBe percentRemaining

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true


    describe 'with an error', ->

      beforeEach ->
        deferredGetInvitations.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.getInvitationsError).toBe true

      it 'should clear a loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true


  describe 'when the modal loads', ->
    modal = null

    beforeEach ->
      modal =
        remove: jasmine.createSpy 'modal.remove'
        hide: jasmine.createSpy 'modal.hide'
      deferredTemplate.resolve modal
      scope.$apply()

    it 'should save the modal on the controller', ->
      expect(ctrl.setPlaceModal).toBe modal

    describe 'then the modal is hidden', ->

      beforeEach ->
        scope.$broadcast '$destroy'
        scope.$apply()

      it 'should clean up the modal', ->
        expect(modal.remove).toHaveBeenCalled()


    describe 'hiding the guest list modal', ->

      beforeEach ->
        scope.hidePlaceModal()

      it 'should hide the modal', ->
        expect(modal.hide).toHaveBeenCalled()


  describe 'building the items list', ->
    acceptedInvitation = null
    maybeInvitation = null
    invitations = null
    friendWithUsername = null
    builtItems = null
    newestMessage = null

    beforeEach ->
      # Mock invitations to events the user has joined.
      event = invitation.event
      oldTimestamp = 1
      newTimestamp = 2
      acceptedInvitation = angular.extend {}, invitation,
        id: 2
        response: Invitation.accepted
        event: angular.extend {}, event,
          id: 2
          latestMessage:
            createdAt: newTimestamp
      maybeInvitation = angular.extend {}, invitation,
        id: 3
        response: Invitation.maybe
        event: angular.extend {}, event,
          id: 3
          latestMessage:
            createdAt: oldTimestamp
      invitationsArray = [
        acceptedInvitation
        maybeInvitation
      ]
      invitations = {}
      for invitation in invitationsArray
        invitations[invitation.id] = invitation

      # Mock the user's friends.
      friendWithUsername =
        id: 2
        username: 'a$ap'
        name: 'A$AP Rocky'
        firstName: 'A$AP'
        lastName: 'Rocky'
        imageUrl: 'https://facebook.com/a$ap/pic'
      friendWithoutUsername =
        id: 3
        username: null
        name: 'Stephan Curry'
      friends = [friendWithUsername, friendWithoutUsername]
      Auth.user.friends = {}
      for friend in friends
        Auth.user.friends[friend.id] = friend
      # TODO: Sort the friends by latest message, then distance.

      newestMessage = 'newestMessage'
      spyOn(ctrl, 'getNewestMessage').and.returnValue newestMessage

      builtItems = ctrl.buildItems invitations

    it 'should return the items', ->
      items = []
      title = 'Plans'
      items.push
        isDivider: true
        title: title
        id: title
      for id, invitation of invitations
        items.push angular.extend
          isDivider: false
          invitation: invitation
          id: invitation.id
          newestMessage: newestMessage
      title = 'Friends'
      items.push
        isDivider: true
        title: title
        id: title
      items.push angular.extend
        isDivider: false
        friend: new User friendWithUsername
        id: friendWithUsername.id
      expect(builtItems).toEqual items


  describe 'subscribing to events\' messages', ->
    event = null

    beforeEach ->
      scope.$meteorSubscribe = jasmine.createSpy 'scope.$meteorSubscribe'
      event = invitation.event
      events = [event]

      ctrl.eventsMessagesSubscribe events

    it 'should subscribe to the events messages', ->
      expect(scope.$meteorSubscribe).toHaveBeenCalledWith 'chat', "#{event.id}"


  describe 'getting the newest message', ->
    chatId = null
    meteorObject = null
    result = null

    beforeEach ->
      chatId = "3"
      meteorObject = 'meteorObject'
      scope.$meteorObject = jasmine.createSpy('scope.$meteorObject')
        .and.returnValue meteorObject
      result = ctrl.getNewestMessage chatId

    it 'should return an AngularMeteorObject', ->
      expect(result).toBe meteorObject

    it 'should query, sort and transform the message', ->
      selector =
        chatId: chatId
      options =
        sort:
          createdAt: -1
        transform: ctrl.transformMessage
      expect(scope.$meteorObject).toHaveBeenCalledWith(ctrl.Messages, selector,
          false, options)


  describe 'transforming a message', ->

    describe 'when the message is of type text', ->
      message = null
      result = null
      chat = null

      beforeEach ->
        chat = 'chat'
        scope.$meteorObject = jasmine.createSpy('scope.$meteorObject')
          .and.returnValue chat

        message =
          type: 'text'
          text: 'Hi Guys!'
          creator:
            firstName: 'Jimbo'

        result = ctrl.transformMessage angular.copy(message)

      it 'should update the message text', ->
        expectedText = "#{message.creator.firstName}: #{message.text}"
        expect(result.text).toEqual expectedText

      it 'should bind the chat to the message', ->
        expect(result.chat).toEqual chat


  describe 'checking if a message was read', ->

    describe 'when message the data has\'t loaded yet', ->
      result = null

      beforeEach ->
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
          chat:
            members: [
              userId: "1",
              lastRead: new Date 1000
            ]

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
          chat:
            members: [
              userId: "1",
              lastRead: new Date 10
            ]

        result = ctrl.wasRead message

      it 'should return false', ->
        expect(result).toBe false


  describe 'responding to an invitation', ->
    date = null
    $event = null
    deferred = null
    originalResponse = null
    newResponse = null
    originalInvitations = null
    originalInvitation = null
    builtItems = null

    beforeEach ->
      jasmine.clock().install()
      date = new Date 1438014089235
      jasmine.clock().mockDate date

      deferred = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise
      builtItems = []
      spyOn(ctrl, 'buildItems').and.returnValue builtItems

      # Mock the invitations saved on the controller.
      ctrl.invitations =
        "#{item.invitation.id}": item.invitation

      # Save the invitations before the item gets updated so that we can
      # compare the updated invitations to the original.
      originalInvitation = angular.copy item.invitation
      originalInvitations = angular.copy ctrl.invitations
      originalResponse = item.invitation.response

      $event =
        stopPropagation: jasmine.createSpy '$event.stopPropagation'
      newResponse = Invitation.accepted
      ctrl.respondToInvitation item, $event, newResponse

    afterEach ->
      jasmine.clock().uninstall()

    it 'should stop the event from propagating', ->
      expect($event.stopPropagation).toHaveBeenCalled()

    it 'should update the invitation', ->
      expect(Invitation.updateResponse).toHaveBeenCalledWith originalInvitation, \
          newResponse

    it 'should rebuild the items array', ->
      expect(ctrl.buildItems).toHaveBeenCalledWith ctrl.invitations

    it 'should save the new items on the controller', ->
      expect(ctrl.items).toBe builtItems


  describe 'accepting an invitation', ->
    invitation = null
    event = null

    beforeEach ->
      spyOn ctrl, 'respondToInvitation'

      invitation = {id: 1}
      event = 'event'
      ctrl.acceptInvitation invitation, event

    it 'should respond to the invitation', ->
      expect(ctrl.respondToInvitation).toHaveBeenCalledWith(invitation, event,
          Invitation.accepted)


  describe 'responding maybe an invitation', ->
    invitation = null
    event = null

    beforeEach ->
      spyOn ctrl, 'respondToInvitation'

      invitation = {id: 1}
      event = 'event'
      ctrl.maybeInvitation invitation, event

    it 'should respond to the invitation', ->
      expect(ctrl.respondToInvitation).toHaveBeenCalledWith(invitation, event,
          Invitation.maybe)


  describe 'declining an invitation', ->
    invitation = null
    event = null

    beforeEach ->
      spyOn ctrl, 'respondToInvitation'

      invitation = {id: 1}
      event = 'event'
      ctrl.declineInvitation invitation, event

    it 'should respond to the invitation', ->
      expect(ctrl.respondToInvitation).toHaveBeenCalledWith(invitation, event,
          Invitation.declined)


  describe 'manually refreshing', ->

    beforeEach ->
      ctrl.isLoading = false
      spyOn ctrl, 'getInvitations'

      ctrl.manualRefresh()

    it 'should set a loading flag', ->
      expect(ctrl.isLoading).toBe true

    it 'should get the invitations', ->
      expect(ctrl.getInvitations).toHaveBeenCalled()


  describe 'viewing an event chat', ->
    invitation = null

    beforeEach ->
      spyOn $state, 'go'
      invitation =
        event:
          id: 1
      item =
        invitation: invitation
      ctrl.viewEventChat item

    it 'should go to the event chat', ->
      expect($state.go).toHaveBeenCalledWith 'event',
        invitation: invitation
        id: invitation.event.id


  describe 'viewing an friend chat', ->
    friend = null

    beforeEach ->
      spyOn $state, 'go'
      friend =
        id: 1
      item =
        friend: friend
      ctrl.viewFriendChat item

    it 'should go to the friend chat', ->
      expect($state.go).toHaveBeenCalledWith 'friendship',
        friend: friend
        id: item.friend.id


  describe 'tapping to add by username', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addByUsername()

    it 'should go to the add by username view', ->
      expect($state.go).toHaveBeenCalledWith 'addByUsername'


  describe 'tapping to add from address book', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromAddressBook()

    it 'should go to the add from address book view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromAddressBook'


  describe 'tapping to add from facebook', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromFacebook()

    it 'should go to the add from facebook view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromFacebook'


  describe 'checking how far away a friend is', ->
    distanceAway = null
    friend = null
    returnedDistanceAway = null

    describe 'when distance can be calculated', ->

      beforeEach ->
        distanceAway = 'distanceAway'
        spyOn(Auth, 'getDistanceAway').and.returnValue distanceAway
        friend =
          id: 2
          location:
            lat: 40.7138251
            long: -73.9897481

        returnedDistanceAway = ctrl.getDistanceAway friend

      it 'should check how far away they are', ->
        expect(Auth.getDistanceAway).toHaveBeenCalledWith friend.location

      it 'should return the distance away', ->
        expect(returnedDistanceAway).toBe distanceAway

    describe 'when distance is unknown', ->

      beforeEach ->
        spyOn(Auth, 'getDistanceAway').and.returnValue null
        friend =
          id: 2
        returnedDistanceAway = ctrl.getDistanceAway friend

      it 'should show the default message', ->
        expect(returnedDistanceAway).toBe 'Start a chat'
