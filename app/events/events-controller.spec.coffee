require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require 'ng-cordova'
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
  dividerHeight = null
  earlier = null
  Event = null
  eventHeight = null
  item = null
  invitation = null
  later = null
  Invitation = null
  scope = null
  transitionDuration = null
  User = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.asteroid')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.events')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngCordova')

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
    dividerHeight = $injector.get 'dividerHeight'
    Event = $injector.get 'Event'
    eventHeight = $injector.get 'eventHeight'
    Invitation = $injector.get 'Invitation'
    scope = $rootScope.$new()
    transitionDuration = $injector.get 'transitionDuration'
    User = $injector.get 'User'

    earlier = new Date()
    later = new Date(earlier.getTime()+1)
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

    describe 'successfully', ->
      modal = null

      beforeEach ->
        modal = 'modal'
        deferredTemplate.resolve modal
        scope.$apply()

      it 'should save the modal on the controller', ->
        expect(ctrl.setPlaceModal).toBe modal


    xdescribe 'unsuccessfully', ->
      # TODO


  describe 'setting item positions', ->
    items = null

    beforeEach ->
      items = [
        isDivider: true
        title: 'Down'
      ,
        isDivider: false
        wasJoined: true
      ,
        isDivider: true
        title: 'Maybe'
      ,
        isDivider: false
        wasJoined: true
      ]
      ctrl.setPositions items

    it 'should set a top property', ->
      top = 0
      for item in items
        expect(item.top).toBe top
        if item.isDivider
          top += dividerHeight
        else
          top += eventHeight

    it 'should set a right property', ->
      for item in items
        expect(item.right).toBe 0


  describe 'building the items list', ->
    noResponseInvitation = null
    newAcceptedInvitation = null
    oldAcceptedInvitation = null
    newMaybeInvitation = null
    oldMaybeInvitation = null
    declinedInvitation = null
    invitations = null
    builtItems = null

    beforeEach ->
      event = invitation.event
      noResponseInvitation = angular.extend {}, invitation,
        id: 2
        response: Invitation.noResponse
        event: angular.extend event,
          id: 2
      newAcceptedInvitation = angular.extend {}, invitation,
        id: 4
        response: Invitation.accepted
        event: angular.extend event,
          id: 4
          latestMessage:
            createdAt: 10
      oldAcceptedInvitation = angular.extend {}, invitation,
        id: 3
        response: Invitation.accepted
        event: angular.extend event,
          id: 3
          latestMessage:
            createdAt: 1
      newMaybeInvitation = angular.extend {}, invitation,
        id: 6
        response: Invitation.maybe
        event: angular.extend event,
          id: 6
          latestMessage:
            createdAt: 10
      oldMaybeInvitation = angular.extend {}, invitation,
        id: 5
        response: Invitation.maybe
        event: angular.extend event,
          id: 5
          latestMessage:
            createdAt: 1
      declinedInvitation = angular.extend {}, invitation,
        id: 7
        response: Invitation.declined
        event: angular.extend event,
          id: 7
      invitationsArray = [
        noResponseInvitation
        newAcceptedInvitation
        oldAcceptedInvitation
        newMaybeInvitation
        oldMaybeInvitation
        declinedInvitation
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
      items.push angular.extend
        isDivider: false
        wasJoined: false
        invitation: noResponseInvitation
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
        items.push angular.extend
          isDivider: false
          wasJoined: true
          invitation: _invitations.newInvitation
        items.push angular.extend
          isDivider: false
          wasJoined: true
          invitation: _invitations.oldInvitation
      items.push
        isDivider: true
        title: 'Can\'t'
      items.push angular.extend
        isDivider: false
        wasJoined: false
        invitation: declinedInvitation
      ctrl.setPositions items
      expect(items).toEqual items


  describe 'moving an item', ->
    items = null
    invitations = null

    beforeEach ->
      event = invitation.event
      noResponseInvitation = angular.extend {}, invitation,
        id: 2
        response: Invitation.noResponse
        event: angular.extend {}, event,
          id: 3
      acceptedInvitation = angular.extend {}, invitation,
        id: 4
        response: Invitation.accepted
        event: angular.extend {}, event,
          id: 5
      ctrl.items = []
      ctrl.items.push
        isDivider: true
        title: 'New'
      ctrl.items.push angular.extend
        isDivider: false
        wasJoined: false
        isExpanded: true
        invitation: noResponseInvitation
      ctrl.items.push
        isDivider: true
        title: 'Down'
      ctrl.items.push angular.extend
        isDivider: false
        wasJoined: true
        isExpanded: false
        invitation: acceptedInvitation
      ctrl.setPositions ctrl.items

      # Save the current items so that we can check equality later.
      items = ctrl.items

      # Update the item's response.
      item.response = Invitation.maybe

      # Mock the window's innerWidth so that we can use it to set the right
      # property on items we remove.
      $window.innerWidth = 10

      noResponseInvitation.response = item.response
      invitations = [noResponseInvitation, acceptedInvitation]
      ctrl.moveItem item, invitations

    it 'should set a moving flag', ->
      expect(ctrl.moving).toBe true

    it 'should collapse the item', ->
      expect(item.isExpanded).toBe false

    it 'should set a reordering property on the item', ->
      expect(item.isReordering).toBe true

    describe 'after a timeout', ->

      beforeEach ->
        $timeout.flush 0

      it 'should update the items\' positions', ->
        expect(ctrl.items).toBe items
        expect(ctrl.items[0].right).toBe $window.innerWidth
        expect(ctrl.items[2].top).toBe 0
        expect(ctrl.items[3].top).toBe dividerHeight
        expect(ctrl.items[1].top).toBe dividerHeight+eventHeight+dividerHeight

      describe 'after time passes', ->

        beforeEach ->
          $timeout.flush transitionDuration
          scope.$apply()

        it 'should unset the moving flag', ->
          expect(ctrl.moving).toBe false

        it 'should replace the old items with the new ones', ->
          expect(ctrl.items).toEqual ctrl.buildItems(invitations)


  describe 'checking whether two items are the same', ->
    item1 = null
    item2 = null

    describe 'when both are dividers', ->

      beforeEach ->
        item1 =
          isDivider: true
          title: 'Down'

      describe 'that are the same', ->

        beforeEach ->
          item2 = angular.copy item1

        it 'should return true', ->
          expect(ctrl.areItemsEqual item1, item2).toBe true


      describe 'that are different', ->

        beforeEach ->
          item2 =
            isDivider: true
            title: 'Maybe'

        it 'should return false', ->
          expect(ctrl.areItemsEqual item1, item2).toBe false


    describe 'when both are invitations', ->

      beforeEach ->
        item1 = angular.copy item

      describe 'that are the same', ->

        beforeEach ->
          item2 = angular.copy item1

        it 'should return true', ->
          expect(ctrl.areItemsEqual item1, item2).toBe true


      describe 'that are different', ->

        beforeEach ->
          invitation = angular.extend {}, item1.invitation,
            id: item1.invitation.id + 1
          item2 = angular.copy item1
          item2.invitation = invitation

        it 'should return false', ->
          expect(ctrl.areItemsEqual item1, item2).toBe false


    describe 'when one is a divider and another is an invitation', ->

      beforeEach ->
        item1 =
          isDivider: true
          title: 'Down'
        item2 = angular.copy item

      it 'should return false', ->
        expect(ctrl.areItemsEqual item1, item2).toBe false


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
        expect(Asteroid.subscribe).toHaveBeenCalledWith 'messages', event.id

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


      describe 'message is new', ->

        beforeEach ->
          spyOn(ctrl, 'isNewMessage').and.returnValue true
          onChange changedDocId

        it 'should call isNewMessage with doc _id', ->
          expect(ctrl.isNewMessage).toHaveBeenCalledWith event, changedDocId

        it 'should set the latest message on the event', ->
          expect(ctrl.setLatestMessage).toHaveBeenCalledWith event, messagesRQ.result


      describe 'message is not new', ->

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
            createdAt: new Date(oldMessage.createdAt.$date)
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
            createdAt: new Date(newMessage.createdAt.$date)
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

      spyOn ctrl, 'moveItem'
      spyOn(ctrl, 'getWasRead').and.returnValue true

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
        createdAt = new Date(textMessage.createdAt.$date)
        expect(event.latestMessage.createdAt).toEqual createdAt

      it 'should move the updated item', ->
        expect(ctrl.moveItem).toHaveBeenCalledWith item, ctrl.invitations


    describe 'when the latest message is an action', ->

      beforeEach ->
        actionMessage.createdAt.$date = later.getTime()
        textMessage.createdAt.$date = earlier.getTime()

        ctrl.setLatestMessage event, messages

      it 'should set the most recent message on the event', ->
        expect(event.latestMessage.text).toBe actionMessage.text

      it 'should update the messages createdAt time', ->
        createdAt = new Date(actionMessage.createdAt.$date)
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
            userId: "1"
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
            userId: '1'
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


  describe 'responding to an invitation', ->
    date = null
    $event = null
    deferred = null
    originalResponse = null
    newResponse = null
    originalInvitations = null
    originalInvitation = null

    beforeEach ->
      jasmine.clock().install()
      date = new Date(1438014089235)
      jasmine.clock().mockDate date

      deferred = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise
      spyOn ctrl, 'moveItem'

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

    it 'should move the item in the items array', ->
      expect(ctrl.moveItem).toHaveBeenCalledWith item, originalInvitations

    describe 'when the update fails', ->

      beforeEach ->
        ctrl.moveItem.calls.reset()

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(item.respondError).toBe true

      it 'should move the item back to the original location', ->
        # TODO: Test this live.
        expect(ctrl.moveItem).toHaveBeenCalledWith item, originalInvitations

      describe 'then trying again', ->

        beforeEach ->
          ctrl.respondToInvitation item, $event, originalResponse

        it 'should clear the error', ->
          expect(item.respondError).toBeNull()


  describe 'accepting an invitation', ->
    $event = null

    beforeEach ->
      spyOn ctrl, 'respondToInvitation'

      $event = '$event'
      ctrl.acceptInvitation item, $event

    it 'should respond to the invitation', ->
      expect(ctrl.respondToInvitation).toHaveBeenCalledWith item, $event, \
          Invitation.accepted


  describe 'responding maybe to an invitation', ->
    $event = null

    beforeEach ->
      spyOn ctrl, 'respondToInvitation'

      $event = '$event'
      ctrl.maybeInvitation item, $event

    it 'should respond to the invitation', ->
      expect(ctrl.respondToInvitation).toHaveBeenCalledWith item, $event, \
          Invitation.maybe


  describe 'declining an invitation', ->
    $event = null

    beforeEach ->
      spyOn ctrl, 'respondToInvitation'

      $event = '$event'
      ctrl.declineInvitation item, $event

    it 'should respond to the invitation', ->
      expect(ctrl.respondToInvitation).toHaveBeenCalledWith item, $event, \
          Invitation.declined


  describe 'checking whether an item was declined', ->

    describe 'when it was declined', ->

      beforeEach ->
        item.invitation.response = Invitation.declined

      it 'should return true', ->
        expect(ctrl.itemWasDeclined item).toBe true


    describe 'when it wasn\'t declined', ->

      beforeEach ->
        item.invitation.response = Invitation.accepted

      it 'should return false', ->
        expect(ctrl.itemWasDeclined item).toBe false


  describe 'toggling setting the date', ->
    deferredDatePicker = null

    beforeEach ->
      deferredDatePicker = $q.defer()
      spyOn($cordovaDatePicker, 'show').and.returnValue deferredDatePicker.promise

    describe 'when there\'s no date right now', ->

      beforeEach ->
        ctrl.hasDate = false
        ctrl.newEvent =
          datetime: new Date(1438195002656)

        ctrl.toggleHasDate()

      it 'should show the datepicker', ->
        options =
          mode: 'datetime'
          date: ctrl.newEvent.datetime
          allowOldDates: false
          doneButtonLabel: 'Set Date'
        expect($cordovaDatePicker.show).toHaveBeenCalledWith options

      describe 'then a date gets set', ->
        newDate = null

        beforeEach ->
          newDate = new Date(1438195002657)
          deferredDatePicker.resolve newDate
          scope.$apply()

        it 'should set the date on the new event', ->
          expect(ctrl.newEvent.datetime).toBe newDate

        it 'should set a flag', ->
          expect(ctrl.newEvent.hasDate).toBe true


    describe 'when the date hasn\'t been set yet', ->
      date = null

      beforeEach ->
        jasmine.clock().install()
        date = new Date(1438195002656)
        jasmine.clock().mockDate date

        ctrl.newEvent = {}

        ctrl.toggleHasDate()

      afterEach ->
        jasmine.clock().uninstall()

      it 'should show the datepicker', ->
        options =
          mode: 'datetime'
          date: date
          allowOldDates: false
          doneButtonLabel: 'Set Date'
        expect($cordovaDatePicker.show).toHaveBeenCalledWith options


    describe 'when the date is showing', ->

      beforeEach ->
        ctrl.newEvent.hasDate = true

        ctrl.toggleHasDate()

      it 'should hide the date', ->
        expect(ctrl.newEvent.hasDate).toBe false


  describe 'toggling setting a place', ->

    describe 'when the event doesn\'t have a place', ->

      beforeEach ->
        ctrl.setPlaceModal =
          show: jasmine.createSpy 'setPlaceModal.show'

        ctrl.toggleHasPlace()

      it 'should show the set place modal', ->
        expect(ctrl.setPlaceModal.show).toHaveBeenCalled()


    describe 'when the event has a place', ->

      beforeEach ->
        ctrl.newEvent.hasPlace = true

        ctrl.toggleHasPlace()

      it 'should hide the location input', ->
        expect(ctrl.newEvent.hasPlace).toBe false


  describe 'toggling adding a comment', ->

    describe 'when the comment isn\'t shown', ->

      beforeEach ->
        ctrl.toggleHasComment()

      it 'should set a flag', ->
        expect(ctrl.newEvent.hasComment).toBe true


    describe 'when the comment input is showing', ->

      beforeEach ->
        ctrl.newEvent.hasComment = true

        ctrl.toggleHasComment()

      it 'should hide the comment input', ->
        expect(ctrl.newEvent.hasComment).toBe false


  describe 'hiding the set place modal', ->

    beforeEach ->
      ctrl.setPlaceModal =
        hide: jasmine.createSpy 'setPlaceModal.hide'

      scope.hidePlaceModal()

    it 'should hide the modal', ->
      expect(ctrl.setPlaceModal.hide).toHaveBeenCalled()


  describe 'cleaning up the set place modal', ->

    beforeEach ->
      ctrl.setPlaceModal =
        remove: jasmine.createSpy 'setPlaceModal.remove'

      scope.$broadcast '$destroy'

    it 'should remove the modal', ->
      expect(ctrl.setPlaceModal.remove).toHaveBeenCalled()


  describe 'setting a place', ->
    place = null

    beforeEach ->
      spyOn scope, 'hidePlaceModal'

      place =
        name: 'Pianos'
        geometry:
          location:
            G: 40.721025
            K: -73.987692
      scope.$broadcast 'placeAutocomplete:placeChanged', place

    it 'should mark the new event as having a place', ->
      expect(ctrl.newEvent.hasPlace).toBe true

    it 'should set the place on the new event', ->
      expect(ctrl.newEvent.place).toEqual
        name: place.name
        lat: place.geometry.location.G
        long: place.geometry.location.K

    it 'should close the modal', ->
      expect(scope.hidePlaceModal).toHaveBeenCalled()


  describe 'inviting friends', ->
    newEvent = null

    beforeEach ->
      ctrl.newEvent =
        title: 'bars?!?!?!?'
        hasDate: false
      # ctrl.getNewEvent creates an event object with attributes set based on
      # which icons are selected.
      newEvent =
        title: ctrl.newEvent.title
      spyOn(ctrl, 'getNewEvent').and.returnValue newEvent
      spyOn $ionicHistory, 'nextViewOptions'
      spyOn $state, 'go'

      ctrl.inviteFriends()

    it 'should disable animating to the next view', ->
      options = {disableAnimate: true}
      expect($ionicHistory.nextViewOptions).toHaveBeenCalledWith options

    it 'should navigate to the invite friends view', ->
      expect($state.go).toHaveBeenCalledWith 'inviteFriends', {event: newEvent}


  describe 'getting the new event', ->

    describe 'when the user only set a title', ->

      beforeEach ->
        ctrl.newEvent =
          title: 'bars?!!?!'

      it 'should set the title on the event', ->
        expect(ctrl.getNewEvent()).toEqual
          title: ctrl.newEvent.title


    describe 'when the user set a date', ->

      beforeEach ->
        ctrl.newEvent =
          title: 'bars?!!?!'
          hasDate: true
          datetime: new Date()

      it 'should set the datetime on the event', ->
        expect(ctrl.getNewEvent()).toEqual
          title: ctrl.newEvent.title
          datetime: ctrl.newEvent.datetime


    describe 'when the user set a place', ->

      beforeEach ->
        ctrl.newEvent =
          title: 'bars?!!?!'
          hasPlace: true
          place:
            name: '169 Bar'
            lat: 40.7138251
            long: -73.9897481

      it 'should set the place on the event', ->
        expect(ctrl.getNewEvent()).toEqual
          title: ctrl.newEvent.title
          place: ctrl.newEvent.place


    describe 'when the user added a comment', ->

      beforeEach ->
        ctrl.newEvent =
          title: 'bars?!!?!'
          hasComment: true
          comment: 'Who doesn\'t love go go dancers?'

      it 'should set the place on the event', ->
        expect(ctrl.getNewEvent()).toEqual
          title: ctrl.newEvent.title
          comment: ctrl.newEvent.comment


  describe 'tapping to view my friends', ->

    beforeEach ->
      spyOn $ionicHistory, 'nextViewOptions'
      spyOn $state, 'go'

      ctrl.myFriends()

    it 'should disable animating to the next view', ->
      options = {disableAnimate: true}
      expect($ionicHistory.nextViewOptions).toHaveBeenCalledWith options

    it 'should go to the friends view', ->
      expect($state.go).toHaveBeenCalledWith 'friends'


  describe 'viewing an event group chat', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.viewEvent item

    it 'should go to the event view', ->
      expect($state.go).toHaveBeenCalledWith 'event',
        invitation: item.invitation
        id: item.invitation.event.id


  describe 'pulling to refresh', ->

    beforeEach ->
      spyOn ctrl, 'getInvitations'

      ctrl.refresh()

    it 'should get an updated list of items', ->
      expect(ctrl.getInvitations).toHaveBeenCalled()
