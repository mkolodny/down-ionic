require '../ionic/ionic.js' # for ionic module
require 'angular'
require 'angular-animate' # for ionic module
require 'angular-mocks'
require 'angular-sanitize' # for ionic module
require 'angular-ui-router'
require '../ionic/ionic-angular.js' # for ionic module
require 'ng-cordova'
require 'ng-toast'
require '../common/asteroid/asteroid-module'
require '../common/auth/auth-module'
require './events-module'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $compile = null
  $cordovaDatePicker = null
  $httpBackend = null
  $ionicHistory = null
  $ionicModal = null
  $q = null
  $state = null
  $timeout = null
  $window = null
  Asteroid = null
  Auth = null
  ctrl = null
  deferredGetInvitations = null
  deferredTemplate = null
  earlier = null
  Event = null
  item = null
  invitation = null
  later = null
  Invitation = null
  ngToast = null
  scope = null
  User = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.asteroid')

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
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $timeout = $injector.get '$timeout'
    $window = $injector.get '$window'
    Asteroid = $injector.get 'Asteroid'
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
      previouslyAccepted: false
      open: false
      muted: false
      lastViewed: later
      createdAt: new Date()
      updatedAt: new Date()
    item =
      isDivider: false
      wasJoined: true
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
      modal = 'modal'
      deferredTemplate.resolve modal
      scope.$apply()

    it 'should save the modal on the controller', ->
      expect(ctrl.setPlaceModal).toBe modal


  describe 'building the items list', ->
    newNoResponseInvitation = null
    oldNoResponseInvitation = null
    newAcceptedInvitation = null
    oldAcceptedInvitation = null
    newMaybeInvitation = null
    oldMaybeInvitation = null
    newDeclinedInvitation = null
    oldDeclinedInvitation = null
    invitations = null
    builtItems = null

    beforeEach ->
      event = invitation.event
      oldTimestamp = 1
      newTimestamp = 2
      newNoResponseInvitation = angular.extend {}, invitation,
        id: 2
        response: Invitation.noResponse
        event: angular.extend {}, event,
          id: 2
          latestMessage:
            createdAt: newTimestamp
      oldNoResponseInvitation = angular.extend {}, invitation,
        id: 3
        response: Invitation.noResponse
        event: angular.extend {}, event,
          id: 3
          latestMessage:
            createdAt: oldTimestamp
      newAcceptedInvitation = angular.extend {}, invitation,
        id: 4
        response: Invitation.accepted
        event: angular.extend {}, event,
          id: 4
          latestMessage:
            createdAt: newTimestamp
      oldAcceptedInvitation = angular.extend {}, invitation,
        id: 5
        response: Invitation.accepted
        event: angular.extend {}, event,
          id: 5
          createdAt: oldTimestamp
      delete oldAcceptedInvitation.event.latestMessage
      newMaybeInvitation = angular.extend {}, invitation,
        id: 6
        response: Invitation.maybe
        event: angular.extend {}, event,
          id: 6
          createdAt: newTimestamp
      delete newMaybeInvitation.event.latestMessage
      oldMaybeInvitation = angular.extend {}, invitation,
        id: 7
        response: Invitation.maybe
        event: angular.extend {}, event,
          id: 7
          latestMessage:
            createdAt: oldTimestamp
      newDeclinedInvitation = angular.extend {}, invitation,
        id: 8
        response: Invitation.declined
        event: angular.extend {}, event,
          id: 8
          createdAt: newTimestamp
      oldDeclinedInvitation = angular.extend {}, invitation,
        id: 9
        response: Invitation.declined
        event: angular.extend {}, event,
          id: 9
          createdAt: oldTimestamp
      invitationsArray = [
        oldNoResponseInvitation
        newNoResponseInvitation
        newAcceptedInvitation
        oldAcceptedInvitation
        oldMaybeInvitation
        newMaybeInvitation
        oldDeclinedInvitation
        newDeclinedInvitation
      ]
      invitations = {}
      for invitation in invitationsArray
        invitations[invitation.id] = invitation

      builtItems = ctrl.buildItems invitations

    it 'should return the items', ->
      items = []
      items.push
        isDivider: true
        title: 'New'
        id: 'New'
      for invitation in [newNoResponseInvitation, oldNoResponseInvitation]
        items.push angular.extend
          isDivider: false
          wasJoined: false
          invitation: invitation
          id: invitation.id
      joinedInvitations =
        'Down':
          newInvitation: newAcceptedInvitation
          oldInvitation: oldAcceptedInvitation
        'Maybe':
          newInvitation: newMaybeInvitation
          oldInvitation: oldMaybeInvitation
      for title, _invitations of joinedInvitations
        items.push
          isDivider: true
          title: title
          id: title
        items.push angular.extend
          isDivider: false
          wasJoined: true
          invitation: _invitations.newInvitation
          id: _invitations.newInvitation.id
        items.push angular.extend
          isDivider: false
          wasJoined: true
          invitation: _invitations.oldInvitation
          id: _invitations.oldInvitation.id
      items.push
        isDivider: true
        title: 'Can\'t'
        id: 'Can\'t'
      for invitation in [newDeclinedInvitation, oldDeclinedInvitation]
        items.push angular.extend
          isDivider: false
          wasJoined: false
          invitation: invitation
          id: invitation.id
      expect(builtItems).toEqual items


  describe 'toggling whether an item is expanded', ->

    describe 'when the item is expanded', ->

      beforeEach ->
        item.isExpanded = true

        ctrl.toggleIsExpanded(item)

      it 'should shrink the item', ->
        expect(item.isExpanded).toBe false


    describe 'when the item isn\'t expanded', ->

      beforeEach ->
        item.isExpanded = false

        ctrl.toggleIsExpanded(item)

      it 'should expand the item', ->
        expect(item.isExpanded).toBe true


  describe 'subscribing to events\' messages', ->
    onChange = null
    messagesRQ = null
    eventsOnChange = null
    eventsRQ = null
    Events = null
    messages = null
    event = null
    events = null

    beforeEach ->
      spyOn Asteroid, 'subscribe'

      messagesRQ =
        result: 'messagesRQ.result'
        on: jasmine.createSpy('messagesRQ.on').and.callFake (name, _onChange_) ->
          onChange = _onChange_
      messages =
        reactiveQuery: jasmine.createSpy('messages.reactiveQuery') \
            .and.returnValue messagesRQ

      eventsRQ =
        result: 'eventsRQ.result'
        on: jasmine.createSpy('eventsRQ.on').and.callFake (name, _onChange_) ->
          eventsOnChange = _onChange_
      Events =
        reactiveQuery: jasmine.createSpy('events.reactiveQuery') \
            .and.returnValue eventsRQ

      spyOn(Asteroid, 'getCollection').and.callFake (collectionName) ->
        if collectionName is 'messages' then return messages
        if collectionName is 'events' then return Events

      spyOn ctrl, 'setLatestMessage'

      event = invitation.event
      events = [event]
      ctrl.eventsMessagesSubscribe events

    it 'should subscribe to each events\' messages', ->
      for event in events
        expect(Asteroid.subscribe).toHaveBeenCalledWith 'event', event.id

    it 'should get the messages collection', ->
      expect(Asteroid.getCollection).toHaveBeenCalledWith 'messages'

    it 'should ask for the messages for each event', ->
      for event in events
        expect(messages.reactiveQuery).toHaveBeenCalledWith {eventId: "#{event.id}"}

    it 'should show each event\'s latest message on the event', ->
      expect(ctrl.setLatestMessage).toHaveBeenCalledWith event, messagesRQ.result

    it 'should listen for new messages', ->
      expect(messagesRQ.on).toHaveBeenCalledWith 'change', jasmine.any(Function)


    describe 'when a message gets posted', ->
      changedDocId = null

      beforeEach ->
        ctrl.setLatestMessage.calls.reset()
        changedDocId = 'asdf'

      describe 'and the message is new', ->

        beforeEach ->
          spyOn(ctrl, 'isNewMessage').and.returnValue true
          onChange changedDocId

        it 'should call isNewMessage with doc _id', ->
          expect(ctrl.isNewMessage).toHaveBeenCalledWith event, changedDocId

        it 'should set the latest message on the event', ->
          expect(ctrl.setLatestMessage).toHaveBeenCalledWith(
              event, messagesRQ.result)


      describe 'and the message is not new', ->

        beforeEach ->
          spyOn(ctrl, 'isNewMessage').and.returnValue false
          onChange changedDocId

        it 'should call isNewMessage with doc _id', ->
          expect(ctrl.isNewMessage).toHaveBeenCalledWith event, changedDocId


    describe 'when a meteor event changes', ->

      beforeEach ->
        spyOn(ctrl, 'getWasRead').and.returnValue true

        event.latestMessage = {}
        event.latestMessage.wasRead = false

        eventsOnChange()

      it 'should set wasRead for the latest message', ->
        expect(event.latestMessage.wasRead).toBe true


  describe 'is new message for event', ->
    oldMessage = null
    newMessage = null
    messagesRQ = null
    messages = null
    isNewMessage = null

    beforeEach ->
      oldMessage =
        _id: 1
        createdAt:
          $date: 1
      newMessage =
        _id: 2
        createdAt:
          $date: 2

      messagesRQ =
        result: 'messagesRQ.result'
      messages =
        reactiveQuery: jasmine.createSpy('messages.reactiveQuery') \
            .and.returnValue messagesRQ
      spyOn(Asteroid, 'getCollection').and.returnValue messages

    describe 'when the message is new', ->

      beforeEach ->
        messagesRQ.result = [newMessage]
        event =
          latestMessage:
            text: 'asdf'
            createdAt: new Date oldMessage.createdAt.$date
        isNewMessage = ctrl.isNewMessage event, newMessage._id

      it 'should query for message object by _id', ->
        expect(messages.reactiveQuery).toHaveBeenCalledWith {_id: newMessage._id}

      it 'should return true', ->
        expect(isNewMessage).toBe true


    describe 'when the message is not new', ->

      beforeEach ->
        messagesRQ.result = [oldMessage]
        event =
          latestMessage:
            createdAt: new Date newMessage.createdAt.$date
            text: 'asdf'
        isNewMessage = ctrl.isNewMessage event, oldMessage._id

      it 'should query for message object by _id', ->
        expect(messages.reactiveQuery).toHaveBeenCalledWith {_id: oldMessage._id}

      it 'should return false', ->
        expect(isNewMessage).toBe false


    describe 'when event doesn\'t have a latest message set', ->

      beforeEach ->
        event = {}
        isNewMessage = ctrl.isNewMessage event, 'asdf'

      it 'should return true', ->
        expect(isNewMessage).toBe true


  describe 'setting an event\'s latest message', ->
    event = null
    textMessage = null
    actionMessage = null
    earlier = null
    later = null
    messages = null
    builtItems = null

    beforeEach ->
      event = invitation.event
      creator =
        id: 2
        name: 'Guido van Rossum'
        firstName: 'Guido'
        lastName: 'van Rossum'
        imageUrl: 'http://facebook.com/profile-pics/vrawesome'
      textMessage =
        _id: 1
        creator: creator
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        eventId: invitation.event.id
        type: 'text'
      actionMessage =
        _id: 1
        creator: creator
        createdAt:
          $date: new Date().getTime()
        text: 'Michael Jordan is down'
        eventId: invitation.event.id
        type: 'action'
      messages = [textMessage, actionMessage]

      # Reset the current items in case they were updated somewhere else.
      ctrl.items = [item]

      spyOn(ctrl, 'getWasRead').and.returnValue true
      builtItems = []
      spyOn(ctrl, 'buildItems').and.returnValue builtItems

    describe 'when the latest message is a text', ->

      beforeEach ->
        textMessage.createdAt.$date = later.getTime()
        actionMessage.createdAt.$date = earlier.getTime()

        ctrl.setLatestMessage event, messages

      it 'should set the most recent message on the event', ->
        message = "#{textMessage.creator.firstName}: #{textMessage.text}"
        expect(event.latestMessage.text).toBe message

      it 'should set unread or read for latest message', ->
        expect(event.latestMessage.wasRead).toBe true
        expect(ctrl.getWasRead).toHaveBeenCalledWith textMessage

      it 'should update the messages createdAt time', ->
        createdAt = new Date textMessage.createdAt.$date
        expect(event.latestMessage.createdAt).toEqual createdAt

      it 'should rebuild the items list', ->
        expect(ctrl.buildItems).toHaveBeenCalledWith ctrl.invitations

      it 'should save the new items on the controller', ->
        expect(ctrl.items).toBe builtItems


    describe 'when the latest message is an action', ->

      beforeEach ->
        actionMessage.createdAt.$date = later.getTime()
        textMessage.createdAt.$date = earlier.getTime()

        ctrl.setLatestMessage event, messages

      it 'should set the most recent message on the event', ->
        expect(event.latestMessage.text).toBe actionMessage.text

      it 'should update the messages createdAt time', ->
        createdAt = new Date actionMessage.createdAt.$date
        expect(event.latestMessage.createdAt).toEqual createdAt

      it 'should set unread or read for latest message', ->
        expect(event.latestMessage.wasRead).toBe true
        expect(ctrl.getWasRead).toHaveBeenCalledWith actionMessage


    describe 'when messages is an empty array', ->

      it 'should return null', ->
        expect(ctrl.setLatestMessage event, []).toBeUndefined()


  describe 'checking is a message is unread', ->
    message = null
    eventsRQ = null
    wasRead = null

    beforeEach ->
      Auth.user =
        id: 1
      message =
        createdAt:
          $date: 10

      eventsRQ =
        result: 'eventsRQ.result'
      events =
        reactiveQuery: jasmine.createSpy('events.reactiveQuery') \
            .and.returnValue eventsRQ
      spyOn(Asteroid, 'getCollection').and.returnValue events

    describe 'when the message has been read', ->

      beforeEach ->
        event =
          members: [
            userId: "#{Auth.user.id}"
            lastRead:
              $date: message.createdAt.$date + 1
          ]
        eventsRQ.result = [event]

        wasRead = ctrl.getWasRead message

      it 'should return true', ->
        expect(wasRead).toBe true


    describe 'when the message hasn\'t been read', ->

      beforeEach ->
        event =
          members: [
            userId: "#{Auth.user.id}"
            lastRead:
              $date: message.createdAt.$date - 1
          ]
        eventsRQ.result = [event]

        wasRead = ctrl.getWasRead message

      it 'should return false', ->
        expect(wasRead).toBe false


    describe 'when the event hasn\'t been returned yet', ->

      beforeEach ->
        eventsRQ.result = [undefined]

        wasRead = ctrl.getWasRead message

      it 'should return true', ->
        expect(wasRead).toBe true


    describe 'when the user isn\'t a member', ->

      beforeEach ->
        event =
          members: [
            userId: "#{Auth.user.id+1}"
            lastRead:
              $date: message.createdAt.$date - 1
          ]
        eventsRQ.result = [event]

        wasRead = ctrl.getWasRead message

      it 'should return true', ->
        expect(wasRead).toBe true


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
