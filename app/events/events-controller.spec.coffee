require '../ionic/ionic.js'
require 'angular'
require 'angular-mocks'
require 'angular-animate'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require 'ng-cordova'
require '../common/asteroid/asteroid-module'
require './events-module'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $compile = null
  $cordovaDatePicker = null
  $httpBackend = null
  $ionicModal = null
  $q = null
  $state = null
  $timeout = null
  $window = null
  Asteroid = null
  ctrl = null
  deferredGetInvitations = null
  deferredTemplate = null
  dividerHeight = null
  earlier = null
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

  beforeEach angular.mock.module('down.events')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngCordova')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $controller = $injector.get '$controller'
    $cordovaDatePicker = $injector.get '$cordovaDatePicker'
    $httpBackend = $injector.get '$httpBackend'
    $ionicModal = $injector.get '$ionicModal'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $timeout = $injector.get '$timeout'
    $window = $injector.get '$window'
    Asteroid = $injector.get 'Asteroid'
    dividerHeight = $injector.get 'dividerHeight'
    eventHeight = $injector.get 'eventHeight'
    Invitation = $injector.get 'Invitation'
    scope = $rootScope.$new()
    transitionDuration = $injector.get 'transitionDuration'
    User = $injector.get 'User'

    earlier = new Date()
    later = new Date(earlier.getTime()+1)
    invitation =
      id: 1
      event:
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
      fromUser:
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
      toUserMessaged: false
      muted: false
      lastViewed: later
      createdAt: new Date()
      updatedAt: new Date()
    item =
      isDivider: false
      wasJoined: true
      wasUpdated: false
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

    describe 'successfully', ->
      items = null
      response = null

      beforeEach ->
        items = 'items'
        spyOn(ctrl, 'buildItems').and.returnValue items
        spyOn ctrl, 'eventsMessagesSubscribe'

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


    describe 'with an error', ->

      beforeEach ->
        deferredGetInvitations.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.getInvitationsError).toBe true

      it 'should clear a loading flag', ->
        expect(ctrl.isLoading).toBe false


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
        wasUpdated: false
      ,
        isDivider: true
        title: 'Maybe'
      ,
        isDivider: false
        wasJoined: true
        wasUpdated: true
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


  describe 'generating the items list', ->
    noResponseInvitation = null
    acceptedInvitation = null
    updatedAcceptedInvitation = null
    maybeInvitation = null
    updatedMaybeInvitation = null
    declinedInvitation = null
    invitations = null

    beforeEach ->
      event = invitation.event
      noResponseInvitation = angular.extend {}, invitation,
        id: 2
        response: Invitation.noResponse
        event: angular.extend event,
          id: 2
      updatedAcceptedInvitation = angular.extend {}, invitation,
        id: 4
        response: Invitation.accepted
        lastViewed: earlier
        event: angular.extend event,
          id: 4
          updatedAt: later
      acceptedInvitation = angular.extend {}, invitation,
        id: 3
        response: Invitation.accepted
        event: angular.extend event,
          id: 3
      updatedMaybeInvitation = angular.extend {}, invitation,
        id: 6
        response: Invitation.maybe
        lastViewed: earlier
        event: angular.extend event,
          id: 6
          updatedAt: later
      maybeInvitation = angular.extend {}, invitation,
        id: 5
        response: Invitation.maybe
        event: angular.extend event,
          id: 5
      declinedInvitation = angular.extend {}, invitation,
        id: 7
        response: Invitation.declined
        event: angular.extend event,
          id: 7
      invitations = [
        noResponseInvitation
        updatedAcceptedInvitation
        acceptedInvitation
        updatedMaybeInvitation
        maybeInvitation
        declinedInvitation
      ]
      ctrl.invitations = {}
      for invitation in invitations
        ctrl.invitations[invitation.id] = invitation

    it 'should return the items', ->
      items = []
      items.push
        isDivider: true
        title: 'New'
      items.push angular.extend
        isDivider: false
        wasJoined: false
        wasUpdated: true
        invitation: noResponseInvitation
      joinedInvitations =
        'Down':
          updatedInvitation: updatedAcceptedInvitation
          oldInvitation: acceptedInvitation
        'Maybe':
          updatedInvitation: updatedMaybeInvitation
          oldInvitation: maybeInvitation
      for title, _invitations of joinedInvitations
        items.push
          isDivider: true
          title: title
        items.push angular.extend
          isDivider: false
          wasJoined: true
          wasUpdated: true
          invitation: _invitations.updatedInvitation
        items.push angular.extend
          isDivider: false
          wasJoined: true
          wasUpdated: false
          invitation: _invitations.oldInvitation
      items.push
        isDivider: true
        title: 'Can\'t'
      items.push angular.extend
        isDivider: false
        wasJoined: false
        wasUpdated: false
        invitation: declinedInvitation
      ctrl.setPositions items
      expect(ctrl.buildItems(ctrl.invitations)).toEqual items


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
        wasUpdated: true
        isExpanded: true
        invitation: noResponseInvitation
      ctrl.items.push
        isDivider: true
        title: 'Down'
      ctrl.items.push angular.extend
        isDivider: false
        wasJoined: true
        wasUpdated: false
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
      spyOn(Asteroid, 'getCollection').and.returnValue messages
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
        expect(messages.reactiveQuery).toHaveBeenCalledWith {eventId: event.id}

    it 'should show each event\'s latest message on the event', ->
      expect(ctrl.setLatestMessage).toHaveBeenCalledWith event, messagesRQ.result

    it 'should listen for new messages', ->
      expect(messagesRQ.on).toHaveBeenCalledWith 'change', jasmine.any(Function)

    describe 'when a new message gets posted', ->

      beforeEach ->
        ctrl.setLatestMessage.calls.reset()

        onChange()

      it 'should set the latest message on the event', ->
        expect(ctrl.setLatestMessage).toHaveBeenCalledWith event, messagesRQ.result


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
        imageUrl: 'http://facebook.com/profile-pics/vrawesome'
      earlier = new Date()
      later = new Date(earlier.getTime() + 1)
      textMessage =
        _id: 1
        creator: creator
        createdAt: new Date()
        text: 'I\'m in love with a robot.'
        eventId: invitation.event.id
        type: 'text'
      actionMessage =
        _id: 1
        creator: creator
        createdAt: new Date()
        text: 'Michael Jordan is down'
        eventId: invitation.event.id
        type: 'action'
      messages = [textMessage, actionMessage]

      # Reset the current items in case they were updated somewhere else.
      ctrl.items = [item]

      spyOn ctrl, 'moveItem'

    describe 'when the latest message is a text', ->

      beforeEach ->
        textMessage.createdAt = later
        actionMessage.createdAt = earlier

        ctrl.setLatestMessage event, messages

      it 'should set the most recent message on the event', ->
        message = "#{textMessage.creator.name}: #{textMessage.text}"
        expect(event.latestMessage).toBe message

      it 'should update the event\'s updatedAt time', ->
        expect(event.updatedAt).toBe textMessage.createdAt

      it 'should move the updated item', ->
        expect(ctrl.moveItem).toHaveBeenCalledWith item, ctrl.invitations


    describe 'when the latest message is an action', ->

      beforeEach ->
        actionMessage.createdAt = later
        textMessage.createdAt = earlier

        ctrl.setLatestMessage event, messages

      it 'should set the most recent message on the event', ->
        expect(event.latestMessage).toBe actionMessage.text


    describe 'when messages is an empty array', ->

      it 'should return null', ->
        expect(ctrl.setLatestMessage event, []).toBeUndefined()


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
      spyOn(Invitation, 'update').and.returnValue {$promise: deferred.promise}
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
      originalInvitation.response = newResponse
      originalInvitation.lastViewed = date
      expect(Invitation.update).toHaveBeenCalledWith originalInvitation

    it 'should move the item in the items array', ->
      invitation = angular.extend originalInvitation,
        response: newResponse
        lastViewed: date
      invitations = originalInvitations
      invitations[invitation.id] = invitation
      expect(ctrl.moveItem).toHaveBeenCalledWith item, invitations

    describe 'when the update succeeds', ->
      updatedInvitation = null

      beforeEach ->
        updatedInvitation = angular.extend {}, originalInvitation,
          response: newResponse
          lastViewed: date
          updatedAt: new Date(1439688265029)
        deferred.resolve updatedInvitation
        scope.$apply()

      it 'should update the invitation\'s updatedAt date', ->
        invitation = ctrl.invitations[item.invitation.id]
        expect(invitation).toEqual updatedInvitation


    describe 'when the update fails', ->

      beforeEach ->
        ctrl.moveItem.calls.reset()

        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(item.respondError).toBe true

      it 'should revert the invitation response', ->
        expect(item.invitation.response).toBe originalResponse

      xit 'should move the item back to the original location', ->
        # TODO: Test this live.
        invitation = angular.extend originalInvitation,
          lastViewed: date
        invitations = originalInvitations
        invitations[invitation.id] = invitation
        expect(ctrl.moveItem).toHaveBeenCalledWith item, invitations

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
      spyOn $state, 'go'

      ctrl.inviteFriends()

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
      spyOn $state, 'go'

      ctrl.myFriends()

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
