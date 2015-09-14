require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require 'ng-toast'
require '../ionic/ionic-angular.js'
require '../common/asteroid/asteroid-module'
require '../common/resources/resources-module'
EventCtrl = require './event-controller'

describe 'event controller', ->
  $ionicActionSheet = null
  $ionicLoading = null
  $ionicPopup = null
  $ionicScrollDelegate = null
  $q = null
  $state = null
  Asteroid = null
  Auth = null
  ctrl = null
  currentDate = null
  earlierMessage = null
  Event = null
  event = null
  invitation = null
  Invitation = null
  LinkInvitation = null
  laterMessage = null
  ngToast = null
  scope = null
  User = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.asteroid')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ngToast')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicActionSheet = $injector.get '$ionicActionSheet'
    $ionicLoading = $injector.get '$ionicLoading'
    $ionicPopup = $injector.get '$ionicPopup'
    $ionicScrollDelegate = $injector.get '$ionicScrollDelegate'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $stateParams = $injector.get '$stateParams'
    Asteroid = $injector.get 'Asteroid'
    Auth = angular.copy $injector.get('Auth')
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'
    LinkInvitation = $injector.get 'LinkInvitation'
    ngToast = $injector.get 'ngToast'
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

  describe 'once the view loads', ->
    Messages = null
    messagesRQ = null
    Events = null
    eventsRQ = null

    beforeEach ->
      spyOn $ionicScrollDelegate, 'scrollBottom'
      spyOn ctrl, 'prepareMessages'

      spyOn Asteroid, 'subscribe'
      # Create mocks/spies for getting the messages for this event, and the event
      #   itself.
      messagesRQ =
        on: jasmine.createSpy 'messagesRQ.on'
      Messages =
        reactiveQuery: jasmine.createSpy('Messages.reactiveQuery') \
            .and.returnValue messagesRQ
      eventsRQ =
        on: jasmine.createSpy 'eventsRQ.on'
      Events =
        reactiveQuery: jasmine.createSpy('Messages.reactiveQuery') \
            .and.returnValue eventsRQ
      spyOn(Asteroid, 'getCollection').and.callFake (collection) ->
        if collection is 'messages'
          Messages
        else if collection is 'events'
          Events

      spyOn ctrl, 'updateMembers'

      scope.$emit '$ionicView.enter'
      scope.$apply()

    it 'should scroll to the bottom of the view', ->
      expect($ionicScrollDelegate.scrollBottom).toHaveBeenCalledWith true

    it 'should call prepare messages', ->
      expect(ctrl.prepareMessages).toHaveBeenCalled()

    it 'should subscribe to the events messages', ->
      expect(Asteroid.subscribe).toHaveBeenCalledWith 'event', event.id

    it 'should get the messages collection', ->
      expect(Asteroid.getCollection).toHaveBeenCalledWith 'messages'

    it 'should set the messages collection on the controller', ->
      expect(ctrl.Messages).toBe Messages

    it 'should ask for the messages for the event', ->
      expect(Messages.reactiveQuery).toHaveBeenCalledWith {eventId: "#{event.id}"}

    it 'should set the messages reactive query on the controller', ->
      expect(ctrl.messagesRQ).toBe messagesRQ

    it 'should listen for new messages', ->
      expect(messagesRQ.on).toHaveBeenCalledWith 'change', \
          ctrl.updateMessages

    it 'should get the events collection', ->
      expect(Asteroid.getCollection).toHaveBeenCalledWith 'events'

    it 'should set the events collection on the controller', ->
      expect(ctrl.Events).toBe Events

    it 'should ask for the event', ->
      expect(Events.reactiveQuery).toHaveBeenCalledWith {_id: "#{event.id}"}

    it 'should set the events reactive query on the controller', ->
      expect(ctrl.eventsRQ).toBe eventsRQ

    it 'should listen for changes to the event', ->
      expect(eventsRQ.on).toHaveBeenCalledWith 'change', \
          ctrl.updateMembers

    it 'should update the members array', ->
      expect(ctrl.updateMembers).toHaveBeenCalled()

    describe 'when new messages get posted', ->
      top = null

      beforeEach ->
        top = 20
        ctrl.maxTop = top + 40
        spyOn($ionicScrollDelegate, 'getScrollPosition').and.returnValue
          top: top

        ctrl.updateMessages()

      it 'should prepare messages', ->
        expect(ctrl.prepareMessages).toHaveBeenCalled()

      describe 'and the user was at the bottom of the view', ->

        beforeEach ->
          ctrl.maxTop = top

        it 'should scroll to the new bottom of the view', ->
          expect($ionicScrollDelegate.scrollBottom).toHaveBeenCalledWith true


  describe 'when leaving the view', ->

    beforeEach ->
      messagesRQ =
        off: jasmine.createSpy 'messagesRQ.off'
      ctrl.messagesRQ = messagesRQ
      eventsRQ =
        off: jasmine.createSpy 'eventsRQ.off'
      ctrl.eventsRQ = eventsRQ

      scope.$broadcast '$ionicView.leave'
      scope.$apply()

    it 'should stop listening for new messages', ->
      expect(ctrl.messagesRQ.off).toHaveBeenCalledWith(
        'change', ctrl.updateMessages)

    it 'should stop listening for new members', ->
      expect(ctrl.eventsRQ.off).toHaveBeenCalledWith(
        'change', ctrl.updateMembers)


  describe 'prepare messages', ->
    messages = null

    beforeEach ->
      # Mock the current date.
      jasmine.clock().install()
      currentDate = new Date 1438195002656
      jasmine.clock().mockDate currentDate

      earlier = new Date()
      later = new Date earlier.getTime()+1
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

      spyOn Asteroid, 'call'

      messagesRQ =
        result: messages
      ctrl.messagesRQ = messagesRQ

      ctrl.messagesRQ
      ctrl.prepareMessages()

    afterEach ->
      jasmine.clock().uninstall()

    it 'should set the messages on the event from oldest to newest', ->
      laterMessage.creator = new User laterMessage.creator
      earlierMessage.creator = new User earlierMessage.creator
      expect(ctrl.messages).toEqual [laterMessage, earlierMessage]

    it 'should mark the newest message as read', ->
      expect(Asteroid.call).toHaveBeenCalledWith 'readMessage', laterMessage._id


  describe 'when the user hits the bottom of the view', ->
    top = null

    beforeEach ->
      top = 20
      spyOn($ionicScrollDelegate, 'getScrollPosition').and.returnValue
        top: top

      ctrl.saveMaxTop()

    it 'should save the current top', ->
      expect(ctrl.maxTop).toBe top


  describe 'updating the members array', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Invitation, 'getMemberInvitations').and.returnValue
        $promise: deferred.promise

      ctrl.updateMembers()

    describe 'successfully', ->
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


    describe 'unsuccessfully', ->

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
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'show an error', ->
        error = 'For some reason, that didn\'t work.'
        expect(ngToast.create).toHaveBeenCalledWith error


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
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'show an error', ->
        error = 'For some reason, that didn\'t work.'
        expect(ngToast.create).toHaveBeenCalledWith error


  describe 'declining the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.accepted
      invitation.response = response

      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'
      deferred = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise
      spyOn $state, 'go'

      ctrl.declineInvitation()

    it 'should show a loading overlay', ->
      expect($ionicLoading.show).toHaveBeenCalled()

    describe 'successfully', ->

      beforeEach ->
        deferred.resolve()
        scope.$apply()

      it 'should update the invitation', ->
        expect(Invitation.updateResponse).toHaveBeenCalledWith invitation, \
            Invitation.declined

      it 'should hide the loading overlay', ->
        expect($ionicLoading.hide).toHaveBeenCalled()

      it 'should go to the events view', ->
        expect($state.go).toHaveBeenCalledWith 'events'


    describe 'unsuccessfully', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'show an error', ->
        error = 'For some reason, that didn\'t work.'
        expect(ngToast.create).toHaveBeenCalledWith error

      it 'should hide the loading overlay', ->
        expect($ionicLoading.hide).toHaveBeenCalled()


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
        buttonClickedCallback 0

      it 'should go to the invite friends view', ->
        stateParams =
          event: ctrl.event
        expect($state.go).toHaveBeenCalledWith 'inviteFriends', stateParams

      it 'should hide the action sheet', ->
        expect(hideSheet).toHaveBeenCalled()


    describe 'tapping the get group link button', ->

      beforeEach ->
        spyOn ctrl, 'getLinkInvitation'
        ctrl.showMoreOptions()
        buttonClickedCallback 1

      it 'should get a link invitation', ->
        expect(ctrl.getLinkInvitation).toHaveBeenCalled()


    describe 'getting a link invitation', ->
      deferred = null

      beforeEach ->
        deferred = $q.defer()
        spyOn(LinkInvitation, 'save').and.returnValue {$promise: deferred.promise}
        spyOn $ionicLoading, 'show'
        spyOn $ionicLoading, 'hide'

        ctrl.getLinkInvitation()

      it 'should show a loading overlay', ->
        expect($ionicLoading.show).toHaveBeenCalled()

      it 'should create a link invitation', ->
        linkInvitation =
          eventId: ctrl.event.id
          fromUserId: Auth.user.id
        expect(LinkInvitation.save).toHaveBeenCalledWith linkInvitation

      describe 'successfully', ->
        linkId = null

        beforeEach ->
          spyOn $ionicPopup, 'alert'
          linkId = 'mikepleb'
          deferred.resolve {linkId: linkId}
          scope.$apply()

        it 'should show a modal with the share link', ->
          expect($ionicPopup.alert).toHaveBeenCalled()

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


      describe 'on error', ->

        beforeEach ->
          spyOn ngToast, 'create'

          deferred.reject()
          scope.$apply()

        it 'should show an error', ->
          error = 'For some reason, that didn\'t work.'
          expect(ngToast.create).toHaveBeenCalledWith error

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


    describe 'when notifications are turned on', ->

      beforeEach ->
        ctrl.invitation.muted = false

        ctrl.showMoreOptions()

      it 'should show an action sheet', ->
        options =
          buttons: [
            text: 'Send To...'
          ,
            text: 'Copy Group Link'
          ,
            text: 'Mute Notifications'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function
        expect($ionicActionSheet.show).toHaveBeenCalledWith options

      describe 'tapping the mute notifications button', ->

        beforeEach ->
          spyOn ctrl, 'toggleNotifications'

          buttonClickedCallback 2

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
            text: 'Send To...'
          ,
            text: 'Copy Group Link'
          ,
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
      spyOn ngToast, 'create'

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
          deferred.resolve ctrl.invitation
          scope.$apply()

        it 'should hide the loading modal', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'show a success message', ->
          message = 'Notifications are on.'
          expect(ngToast.create).toHaveBeenCalledWith message


      describe 'when the update fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should reset the invitation', ->
          expect(ctrl.invitation.muted).toBe false

        it 'show an error', ->
          error = 'For some reason, that didn\'t work.'
          expect(ngToast.create).toHaveBeenCalledWith error

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


    describe 'when notifications are turned off', ->

      beforeEach ->
        ctrl.invitation.muted = true

        ctrl.toggleNotifications()

      it 'should show a loading modal', ->
        expect($ionicLoading.show).toHaveBeenCalled()

      it 'should edit the muted property', ->
        expect(ctrl.invitation.muted).toBe false

      it 'should update the invitation', ->
        originalInvitation.muted = false
        expect(Invitation.update).toHaveBeenCalledWith originalInvitation

      describe 'when the update succeeds', ->

        beforeEach ->
          deferred.resolve ctrl.invitation
          scope.$apply()

        it 'should hide the loading modal', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'show a success message', ->
          message = 'Notifications are off.'
          expect(ngToast.create).toHaveBeenCalledWith message


      describe 'when the update fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should reset the invitation', ->
          expect(ctrl.invitation.muted).toBe true

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()
