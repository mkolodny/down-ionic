require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/asteroid/asteroid-module'
require '../common/resources/resources-module'
EventCtrl = require './event-controller'

describe 'event controller', ->
  $q = null
  $state = null
  Asteroid = null
  Auth = null
  ctrl = null
  deferred = null
  earlierMessage = null
  Event = null
  event = null
  invitation = null
  Invitation = null
  laterMessage = null
  onChange = null
  Messages = null
  messages = null
  messagesRQ = null
  scope = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.asteroid')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $stateParams = $injector.get '$stateParams'
    Asteroid = $injector.get 'Asteroid'
    Auth = angular.copy $injector.get('Asteroid')
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'
    scope = $rootScope.$new true

    # Mock the current event.
    event =
      id: 1
      title: 'bars?!?!!?'
      creator: 2
      canceled: false
      datetime: new Date()
      createdAt: new Date()
      updatedAt: new Date()
      place:
        name: 'B Bar & Grill'
        lat: 40.7270718
        long: -73.9919324
    invitation =
      id: 1
      event: event
      fromUser: 2
      toUser:
        id: 3
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pics/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535
      response: Invitation.Accepted
      previouslyAccepted: false
      toUserMessaged: false
      muted: false
      lastViewed: new Date()
      createdAt: new Date()
      updatedAt: new Date()
    $stateParams.invitation = invitation

    # Mock the current user.
    Auth.user =
      id: 3
      email: 'aturing@gmail.com'
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535

    # Create mocks/spies for getting the messages for this event.
    spyOn Asteroid, 'subscribe'
    earlier = new Date()
    later = new Date(earlier.getTime() + 1)
    creator =
      id: 2
      name: 'Guido van Rossum'
      imageUrl: 'http://facebook.com/profile-pics/vrawesome'
    earlierMessage =
      _id: 1
      creator: creator
      createdAt: new Date()
      text: 'I\'m in love with a robot.'
      eventId: event.id
      type: 'text'
    laterMessage =
      _id: 1
      creator: creator
      createdAt: new Date()
      text: 'Michael Jordan is down'
      eventId: event.id
      type: 'action'
    messages = [earlierMessage, laterMessage]
    messagesRQ =
      result: messages
      on: jasmine.createSpy('messagesRQ.on').and.callFake (name, _onChange_) ->
        onChange = _onChange_
    Messages =
      reactiveQuery: jasmine.createSpy('Messages.reactiveQuery') \
          .and.returnValue messagesRQ
    spyOn(Asteroid, 'getCollection').and.returnValue Messages

    deferred = $q.defer()
    spyOn(Invitation, 'getEventInvitations').and.returnValue
      $promise: deferred.promise

    ctrl = $controller EventCtrl,
      $scope: scope
      Auth: Auth
  )

  it 'should set the user\'s invitation on the controller', ->
    expect(ctrl.invitation).toBe invitation

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  it 'should subscribe to each events\' messages', ->
    expect(Asteroid.subscribe).toHaveBeenCalledWith 'messages', event.id

  it 'should get the messages collection', ->
    expect(Asteroid.getCollection).toHaveBeenCalledWith 'messages'

  it 'should set the messages collection on the controller', ->
    expect(ctrl.Messages).toBe Messages

  it 'should ask for the messages for the event', ->
    expect(Messages.reactiveQuery).toHaveBeenCalledWith {eventId: event.id}

  it 'should set the messages reactive query on the controller', ->
    expect(ctrl.messagesRQ).toBe messagesRQ

  it 'should set the messages on the event from newest to oldest', ->
    expect(ctrl.messages).toEqual [earlierMessage, laterMessage]

  it 'should listen for new messages', ->
    expect(messagesRQ.on).toHaveBeenCalledWith 'change', jasmine.any(Function)

  it 'should request the event members\' invitations', ->
    expect(Invitation.getEventInvitations).toHaveBeenCalledWith {id: event.id}

  describe 'when new messages get posted', ->

    beforeEach ->
      spyOn ctrl, 'sortMessages'

      # Mock the messages being in the wrong order.
      ctrl.messages = [earlierMessage, laterMessage]

      onChange()

    it 'should sort the messages', ->
      expect(ctrl.sortMessages).toHaveBeenCalled()

  describe 'when the invitations return successfully', ->
    invitations = null

    beforeEach ->
      invitations = [invitation]
      deferred.resolve invitations
      scope.$apply()

    it 'should set the invitations on the controller', ->
      members = (invitation.toUser for invitation in invitations)
      expect(ctrl.members).toEqual members


  describe 'when the invitations return unsuccessfully', ->

    beforeEach ->
      deferred.reject()
      scope.$apply()

    it 'should show an error', ->
      # TODO: Show the error in the view.
      expect(ctrl.membersError).toBe true


  describe 'toggling whether the header is expanded', ->

    describe 'when the header is expanded', ->

      beforeEach ->
        ctrl.isHeaderExpanded = true

        ctrl.toggleIsHeaderExpanded()

      it 'should collapse the header', ->
        expect(ctrl.isHeaderExpanded).toBe false


    describe 'when the header is collapsed', ->

      beforeEach ->
        ctrl.isHeaderExpanded = false

        ctrl.toggleIsHeaderExpanded()

      it 'should unexpand the header', ->
        expect(ctrl.isHeaderExpanded).toBe true


  describe 'checking whether the user accepted their invitation', ->

    describe 'when they did', ->

      beforeEach ->
        invitation.response = Invitation.accepted

      it 'should return true', ->
        expect(ctrl.isAccepted()).toBe true


    describe 'when they didn\'t', ->

      beforeEach ->
        invitation.response = Invitation.maybe

      it 'should return false', ->
        expect(ctrl.isAccepted()).toBe false


  describe 'checking whether the user responded maybe their invitation', ->

    describe 'when they did', ->

      beforeEach ->
        invitation.response = Invitation.maybe

      it 'should return true', ->
        expect(ctrl.isMaybe()).toBe true


    describe 'when they didn\'t', ->

      beforeEach ->
        invitation.response = Invitation.accepted

      it 'should return false', ->
        expect(ctrl.isMaybe()).toBe false


  describe 'accepting the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.maybe
      invitation.response = response

      deferred = $q.defer()
      spyOn(Invitation, 'update').and.returnValue {$promise: deferred.promise}

      ctrl.acceptInvitation()

    it 'should set the new response the invitation', ->
      expect(invitation.response).toBe Invitation.accepted

    it 'should update the invitation', ->
      expect(Invitation.update).toHaveBeenCalledWith invitation

    describe 'when the update fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should revert the invitation response', ->
        expect(invitation.response).toBe response

      xit 'show an error', ->


  describe 'responding maybe to the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.accepted
      invitation.response = response

      deferred = $q.defer()
      spyOn(Invitation, 'update').and.returnValue {$promise: deferred.promise}

      ctrl.maybeInvitation()

    it 'should set the new response the invitation', ->
      expect(invitation.response).toBe Invitation.maybe

    it 'should update the invitation', ->
      expect(Invitation.update).toHaveBeenCalledWith invitation

    describe 'when the update fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should revert the invitation response', ->
        expect(invitation.response).toBe response

      xit 'show an error', ->


  describe 'declining the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.accepted
      invitation.response = response

      deferred = $q.defer()
      spyOn(Invitation, 'update').and.returnValue {$promise: deferred.promise}
      spyOn $state, 'go'

      ctrl.declineInvitation()

    it 'should set the new response the invitation', ->
      expect(invitation.response).toBe Invitation.declined

    it 'should update the invitation', ->
      expect(Invitation.update).toHaveBeenCalledWith invitation

    it 'should go to the events view', ->
      expect($state.go).toHaveBeenCalledWith 'events'

    describe 'when the update fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should revert the invitation response', ->
        expect(invitation.response).toBe response

      xit 'show an error', ->


  describe 'checking whether a message is an action message', ->
    message = null

    beforeEach ->
      message = earlierMessage

    describe 'when it is', ->

      beforeEach ->
        message.type = 'action'

      it 'should return true', ->
        expect(ctrl.isActionMessage message).toBe true


    describe 'when it isn\'t', ->

      beforeEach ->
        message.type = 'text'

      it 'should return false', ->
        expect(ctrl.isActionMessage message).toBe false


  describe 'checking whether a message is the current user\'s message', ->
    message = null

    beforeEach ->
      message = earlierMessage
      Auth.user =
        id: 1
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pics/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535

    describe 'when it is', ->

      beforeEach ->
        message.creator.id = Auth.user.id

      it 'should return true', ->
        expect(ctrl.isMyMessage message).toBe true


    describe 'when it isn\'t', ->

      beforeEach ->
        message.creator.id = Auth.user.id + 1

      it 'should return false', ->
        expect(ctrl.isMyMessage message).toBe false


  describe 'sending a message', ->

    beforeEach ->
      ctrl.message = 'this is gonna be dope!'
      spyOn Event, 'sendMessage'

      ctrl.sendMessage()

    it 'should send the message', ->
      expect(Event.sendMessage).toHaveBeenCalledWith event, ctrl.message

    fit 'should clear the message', ->
      expect(ctrl.message).toBeNull()
