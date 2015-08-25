require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require '../common/asteroid/asteroid-module'
require '../common/resources/resources-module'
EventCtrl = require './event-controller'

describe 'event controller', ->
  $ionicActionSheet = null
  $ionicLoading = null
  $ionicScrollDelegate = null
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

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.asteroid')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicActionSheet = $injector.get '$ionicActionSheet'
    $ionicLoading = $injector.get '$ionicLoading'
    $ionicScrollDelegate = $injector.get '$ionicScrollDelegate'
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
      createdAt:
        $date: new Date().getTime()
      text: 'I\'m in love with a robot.'
      eventId: event.id
      type: 'text'
    laterMessage =
      _id: 1
      creator: creator
      createdAt:
        $date: new Date().getTime()
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

  it 'should set the event title on the event', ->
    expect(ctrl.event.titleWithLongVariableName).toBe event.title

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

  it 'should set the messages on the event from oldest to newest', ->
    expect(ctrl.messages).toEqual [laterMessage, earlierMessage]

  it 'should listen for new messages', ->
    expect(messagesRQ.on).toHaveBeenCalledWith 'change', jasmine.any(Function)

  it 'should request the event members\' invitations', ->
    expect(Invitation.getEventInvitations).toHaveBeenCalledWith {id: event.id}

  describe 'once the view loads', ->

    beforeEach ->
      spyOn $ionicScrollDelegate, 'scrollBottom'
      spyOn Invitation, 'update'

      scope.$emit '$ionicView.enter'

    it 'should scroll to the bottom of the view', ->
      expect($ionicScrollDelegate.scrollBottom).toHaveBeenCalledWith true

    it 'should update the last viewed time', ->
      expect(Invitation.update).toHaveBeenCalledWith invitation

  describe 'when new messages get posted', ->
    top = null

    beforeEach ->
      spyOn ctrl, 'sortMessages'
      top = 20
      ctrl.maxTop = top + 40
      spyOn($ionicScrollDelegate, 'getScrollPosition').and.returnValue
        top: top

      # Mock the messages being in the wrong order.
      ctrl.messages = [earlierMessage, laterMessage]

      onChange()

    it 'should sort the messages', ->
      expect(ctrl.sortMessages).toHaveBeenCalled()

    describe 'and the user was at the bottom of the view', ->

      beforeEach ->
        ctrl.maxTop = top
        spyOn $ionicScrollDelegate, 'scrollBottom'

        onChange()

      it 'should scroll to the new bottom of the view', ->
        expect($ionicScrollDelegate.scrollBottom).toHaveBeenCalledWith true


  describe 'when the user hits the bottom of the view', ->
    top = null

    beforeEach ->
      top = 20
      spyOn($ionicScrollDelegate, 'getScrollPosition').and.returnValue
        top: top

      ctrl.saveMaxTop()

    it 'should save the current top', ->
      expect(ctrl.maxTop).toBe top


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


  describe 'sorting messages', ->

    it 'should sort the messages from oldest to newest', ->
      expect(ctrl.messages).toEqual [laterMessage, earlierMessage]


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
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise

      ctrl.acceptInvitation()

    it 'should update the invitation', ->
      expect(Invitation.updateResponse).toHaveBeenCalledWith invitation, \
          Invitation.accepted

    describe 'when the update fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      xit 'show an error', ->


  describe 'responding maybe to the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.accepted
      invitation.response = response

      deferred = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise

      ctrl.maybeInvitation()

    it 'should update the invitation', ->
      expect(Invitation.updateResponse).toHaveBeenCalledWith invitation, \
          Invitation.maybe

    describe 'when the update fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      xit 'show an error', ->


  describe 'declining the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.accepted
      invitation.response = response

      deferred = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise
      spyOn $state, 'go'

      ctrl.declineInvitation()

    it 'should update the invitation', ->
      expect(Invitation.updateResponse).toHaveBeenCalledWith invitation, \
          Invitation.declined

    it 'should go to the events view', ->
      expect($state.go).toHaveBeenCalledWith 'events'

    describe 'when the update fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      xit 'show an error', ->


  describe 'checking whether a message is an action message', ->
    message = null

    beforeEach ->
      message = earlierMessage

    describe 'when it is an accept action', ->

      beforeEach ->
        message.type = Invitation.acceptAction

      it 'should return true', ->
        expect(ctrl.isActionMessage message).toBe true


    describe 'when it is an maybe action', ->

      beforeEach ->
        message.type = Invitation.maybeAction

      it 'should return true', ->
        expect(ctrl.isActionMessage message).toBe true


    describe 'when it is a decline action', ->

      beforeEach ->
        message.type = Invitation.declineAction

      it 'should return true', ->
        expect(ctrl.isActionMessage message).toBe true


    describe 'when it\'s text', ->

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
    message = null

    beforeEach ->
      message = 'this is gonna be dope!'
      ctrl.message = message
      spyOn Event, 'sendMessage'

      ctrl.sendMessage()

    it 'should send the message', ->
      expect(Event.sendMessage).toHaveBeenCalledWith event, message

    it 'should clear the message', ->
      expect(ctrl.message).toBeNull()


  describe 'showing more options', ->
    buttonClickedCallback = null
    hideSheet = null

    beforeEach ->
      spyOn($ionicActionSheet, 'show').and.callFake (options) ->
        buttonClickedCallback = options.buttonClicked
        hideSheet = jasmine.createSpy 'hideSheet'
        hideSheet

    describe 'when notifications are turned on', ->

      beforeEach ->
        ctrl.invitation.muted = false

        ctrl.showMoreOptions()

      it 'should show an action sheet', ->
        options =
          buttons: [
            text: 'Mute Notifications'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function
        expect($ionicActionSheet.show).toHaveBeenCalledWith options

      describe 'tapping the mute notifications button', ->

        beforeEach ->
          spyOn ctrl, 'toggleNotifications'

          buttonClickedCallback 0

        it 'should update the event', ->
          expect(ctrl.toggleNotifications).toHaveBeenCalled()

        it 'should hide the action sheet', ->
          expect(hideSheet).toHaveBeenCalled()


    describe 'when notifications are turned off', ->

      beforeEach ->
        ctrl.invitation.muted = true

        ctrl.showMoreOptions()

      it 'should show an action sheet', ->
        options =
          buttons: [
            text: 'Turn On Notifications'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function
        expect($ionicActionSheet.show).toHaveBeenCalledWith options


  describe 'toggling notifications', ->
    deferred = null
    originalInvitation = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Invitation, 'update').and.returnValue {$promise: deferred.promise}
      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'

      # Save the original invitation.
      originalInvitation = angular.copy invitation

    describe 'when notifications are turned on', ->

      beforeEach ->
        ctrl.invitation.muted = false

        ctrl.toggleNotifications()

      it 'should show a loading modal', ->
        expect($ionicLoading.show).toHaveBeenCalled()

      it 'should edit the muted property', ->
        expect(ctrl.invitation.muted).toBe true

      it 'should update the invitation', ->
        originalInvitation.muted = true
        expect(Invitation.update).toHaveBeenCalledWith originalInvitation

      describe 'when the update succeeds', ->

        beforeEach ->
          deferred.resolve()
          scope.$apply()

        it 'should hide the loading modal', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        xit 'should show a success alert', ->


      describe 'when the update fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should reset the invitation', ->
          expect(ctrl.invitation.muted).toBe false

        xit 'should show an error', ->


    describe 'when notifications are turned off', ->

      beforeEach ->
        ctrl.invitation.muted = true

        ctrl.toggleNotifications()

      xit 'should show a loading modal', ->

      it 'should edit the muted property', ->
        expect(ctrl.invitation.muted).toBe false

      it 'should update the invitation', ->
        originalInvitation.muted = false
        expect(Invitation.update).toHaveBeenCalledWith originalInvitation

      describe 'when the update succeeds', ->

        beforeEach ->
          deferred.resolve()
          scope.$apply()

        it 'should hide the loading modal', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        xit 'should show a success alert', ->


      describe 'when the update fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should reset the invitation', ->
          expect(ctrl.invitation.muted).toBe true
