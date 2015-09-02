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
  currentDate = null
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
  User = null

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
    $state = $injector.get '$state'
    $stateParams = $injector.get '$stateParams'
    Asteroid = $injector.get 'Asteroid'
    Auth = angular.copy $injector.get('Asteroid')
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'
    scope = $injector.get '$rootScope'
    User = $injector.get 'User'

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
      muted: false
      createdAt: new Date()
      updatedAt: new Date()
    $stateParams.invitation = invitation

    # Mock the current user.
    Auth.user = new User
      id: 3
      email: 'aturing@gmail.com'
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535

    deferred = $q.defer()
    spyOn(Invitation, 'getMemberInvitations').and.returnValue
      $promise: deferred.promise

    ctrl = $controller EventCtrl,
      $scope: scope
      Auth: Auth
  )

  afterEach ->
    jasmine.clock().uninstall()

  it 'should set the user\'s invitation on the controller', ->
    expect(ctrl.invitation).toBe invitation

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  it 'should set the event title on the event', ->
    expect(ctrl.event.titleWithLongVariableName).toBe event.title

  it 'should request the event members\' invitations', ->
    expect(Invitation.getMemberInvitations).toHaveBeenCalledWith {id: event.id}

  describe 'once the view loads', ->

    beforeEach ->
      spyOn $ionicScrollDelegate, 'scrollBottom'
      spyOn ctrl, 'prepareMessages'

      spyOn Asteroid, 'subscribe'
      # Create mocks/spies for getting the messages for this event.
      messagesRQ =
        on: jasmine.createSpy('messagesRQ.on').and.callFake (name, _onChange_) ->
          onChange = _onChange_
      Messages =
        reactiveQuery: jasmine.createSpy('Messages.reactiveQuery') \
            .and.returnValue messagesRQ
      spyOn(Asteroid, 'getCollection').and.returnValue Messages

      scope.$emit '$ionicView.enter'
      scope.$apply()

    it 'should scroll to the bottom of the view', ->
      expect($ionicScrollDelegate.scrollBottom).toHaveBeenCalledWith true

    it 'should call prepare messages', ->
      expect(ctrl.prepareMessages).toHaveBeenCalled()

    it 'should subscribe to the events messages', ->
      expect(Asteroid.subscribe).toHaveBeenCalledWith 'messages', event.id

    it 'should get the messages collection', ->
      expect(Asteroid.getCollection).toHaveBeenCalledWith 'messages'

    it 'should set the messages collection on the controller', ->
      expect(ctrl.Messages).toBe Messages

    it 'should ask for the messages for the event', ->
      expect(Messages.reactiveQuery).toHaveBeenCalledWith {eventId: "#{event.id}"}

    it 'should set the messages reactive query on the controller', ->
      expect(ctrl.messagesRQ).toBe messagesRQ

    it 'should listen for new messages', ->
      expect(messagesRQ.on).toHaveBeenCalledWith 'change', jasmine.any(Function)

    describe 'when new messages get posted', ->
      top = null

      beforeEach ->
        top = 20
        ctrl.maxTop = top + 40
        spyOn($ionicScrollDelegate, 'getScrollPosition').and.returnValue
          top: top

        onChange()

      it 'should prepare messages', ->
        expect(ctrl.prepareMessages).toHaveBeenCalled()

      describe 'and the user was at the bottom of the view', ->

        beforeEach ->
          ctrl.maxTop = top

          onChange()

        it 'should scroll to the new bottom of the view', ->
          expect($ionicScrollDelegate.scrollBottom).toHaveBeenCalledWith true


  describe 'when leaving the view', ->

    beforeEach ->
      ctrl.messagesRQ = true

      scope.$broadcast '$ionicView.leave'
      scope.$apply()

    it 'should stop listening for new messages', ->
      expect(ctrl.messagesRQ).toBeUndefined()


  describe 'prepare messages', ->

    beforeEach ->
      # Mock the current date.
      jasmine.clock().install()
      currentDate = new Date(1438195002656)
      jasmine.clock().mockDate currentDate

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
      ctrl.messagesRQ = messagesRQ

      ctrl.messagesRQ
      ctrl.prepareMessages()

    it 'should set the messages on the event from oldest to newest', ->
      laterMessage.creator = new User(laterMessage.creator)
      earlierMessage.creator = new User(earlierMessage.creator)
      expect(ctrl.messages).toEqual [laterMessage, earlierMessage]


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
    acceptedInvitation = null
    maybeInvitation = null
    invitations = null

    beforeEach ->
      acceptedInvitation = angular.extend {}, invitation,
        response: Invitation.accepted
      maybeInvitation = angular.extend {}, invitation,
        response: Invitation.maybe
      invitations = [acceptedInvitation, maybeInvitation]
      deferred.resolve invitations
      scope.$apply()

    it 'should set the accepted/maybe invitations on the controller', ->
      memberInvitations = [acceptedInvitation, maybeInvitation]
      members = (invitation.toUser for invitation in memberInvitations)
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
        message.creator.id = "#{Auth.user.id}" # Meteor likes strings

      it 'should return true', ->
        expect(ctrl.isMyMessage message).toBe true


    describe 'when it isn\'t', ->

      beforeEach ->
        message.creator.id = "#{Auth.user.id + 1}" # Meteor likes strings

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

    describe 'tapping Send To.. button', ->

      beforeEach ->
        spyOn $state, 'go'
        ctrl.showMoreOptions()
        buttonClickedCallback 1

      it 'should go to the invite friends view', ->
        stateParams =
          event: ctrl.event
        expect($state.go).toHaveBeenCalledWith 'inviteFriends', stateParams

      it 'should hide the action sheet', ->
        expect(hideSheet).toHaveBeenCalled()

    describe 'when notifications are turned on', ->

      beforeEach ->
        ctrl.invitation.muted = false

        ctrl.showMoreOptions()

      it 'should show an action sheet', ->
        options =
          buttons: [
            text: 'Mute Notifications'
          ,
            text: 'Send To..'
          ,
            text: 'Report'
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
          ,
            text: 'Send To..'
          ,
            text: 'Report'
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
