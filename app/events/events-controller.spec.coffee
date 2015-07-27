require 'angular'
require 'angular-mocks'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $compile = null
  $q = null
  ctrl = null
  deferred = null
  earlier = null
  item = null
  later = null
  Invitation = null
  scope = null
  User = null

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    Auth = $injector.get 'Auth'
    Invitation = $injector.get 'Invitation'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    earlier = new Date()
    later = new Date(earlier.getTime()+1)
    item =
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

    deferred = $q.defer()
    spyOn(Auth, 'getInvitations').and.returnValue deferred.promise

    ctrl = $controller EventsCtrl,
      $scope: scope
  )

  xdescribe 'when the events request returns', ->

    describe 'successfully', ->
      response = null

      beforeEach ->
        spyOn ctrl, 'buildItems'

        response = [item]
        deferred.resolve response
        scope.$apply()

      it 'should save the invitations on the controller', ->
        invitations = {}
        for invitation in response
          invitations[invitation.id] = invitation
        expect(ctrl.invitations).toEqual invitations

      it 'should generate the items list', ->
        invitations = {}
        for invitation in response
          invitations[invitation.id] = invitation
        expect(ctrl.buildItems).toHaveBeenCalledWith invitations

    describe 'with an error', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.getInvitationsError).toBe true


  describe 'generating the items list', ->
    noResponseInvitation = null
    acceptedInvitation = null
    updatedAcceptedInvitation = null
    maybeInvitation = null
    updatedMaybeInvitation = null
    declinedInvitation = null
    items = null

    beforeEach ->
      invitation = item
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
      ctrl.buildItems invitations

    it 'should set the items on the controller', ->
      items = []
      items.push
        isDivider: true
        title: 'New'
      items.push angular.extend
        isDivider: false
        wasJoined: false
        wasUpdated: true
      , noResponseInvitation
      joinedInvitations =
        'Down':
          updatedInvitation: updatedAcceptedInvitation
          oldInvitation: acceptedInvitation
        'Maybe':
          updatedInvitation: updatedMaybeInvitation
          oldInvitation: maybeInvitation
      for title, invitations of joinedInvitations
        items.push
          isDivider: true
          title: title
        items.push angular.extend
          isDivider: false
          wasJoined: true
          wasUpdated: true
        , invitations.updatedInvitation
        items.push angular.extend
          isDivider: false
          wasJoined: true
          wasUpdated: false
        , invitations.oldInvitation
      items.push
        isDivider: true
        title: 'Can\'t'
      items.push angular.extend
        isDivider: false
        wasJoined: false
        wasUpdated: false
      , declinedInvitation
      expect(ctrl.items).toEqual items


  describe 'moving an item', ->
    noResponseInvitation = null
    item = null
    items = null
    response = null

    beforeEach ->
      invitation = item
      event = invitation.event
      noResponseInvitation = angular.extend {}, invitation,
        id: 2
        response: Invitation.noResponse
        event: angular.extend event,
          id: 2
      ctrl.items = []
      ctrl.items.push
        isDivider: true
        title: 'New'
      item = angular.extend
        isDivider: false
        wasJoined: false
        wasUpdated: true
        isExpanded: true
      , noResponseInvitation
      ctrl.items.push item

      # Save the current items.
      items = ctrl.items

    describe 'when the new section has items', ->
      response = null
      existingItem = null

      beforeEach ->
        response = Invitation.accepted
        item.response = response

        ctrl.items.push
          isDivider: true
          title: ctrl.sections[response].title
        existingItem = angular.extend
          isDivider: false
          wasJoined: false
          wasUpdated: true
          isExpanded: true
        , noResponseInvitation,
          response: response
          id: 7
        ctrl.items.push existingItem

        ctrl.moveItem item, ctrl.items

      it 'should move the item in the items array', ->
        expect(ctrl.items).toBe items
        newItems = []
        newItems.push
          isDivider: true
          title: ctrl.sections[response].title
        newItems.push existingItem
        itemCopy = angular.extend {}, item,
          isExpanded: false
          wasJoined: true
          wasUpdated: false
        newItems.push itemCopy
        expect(ctrl.items).toEqual newItems


    describe 'when the new section has no existing items', ->

      describe 'when the new response is accepted', ->

        beforeEach ->
          response = Invitation.accepted
          item.response = response

          ctrl.moveItem item, ctrl.items

        it 'should move the item in the items array', ->
          expect(ctrl.items).toBe items
          newItems = []
          newItems.push
            isDivider: true
            title: ctrl.sections[response].title
          itemCopy = angular.extend {}, item,
            isExpanded: false
            wasJoined: true
            wasUpdated: false
          newItems.push itemCopy
          expect(ctrl.items).toEqual newItems


      describe 'when the new response is maybe', ->

        beforeEach ->
          response = Invitation.maybe
          item.response = response

        describe 'when there are declined invitations', ->
          acceptedItem = null
          declinedItem = null

          beforeEach ->
            ctrl.items.push
              isDivider: true
              title: ctrl.sections[Invitation.accepted].title
            acceptedItem = angular.extend
              isDivider: false
              wasJoined: true
              wasUpdated: false
            , noResponseInvitation,
              response: Invitation.accepted
              id: 7
            ctrl.items.push acceptedItem
            ctrl.items.push
              isDivider: true
              title: ctrl.sections[Invitation.declined].title
            declinedItem = angular.extend
              isDivider: false
              wasJoined: false
              wasUpdated: false
            , noResponseInvitation,
              response: Invitation.declined
              id: 7
            ctrl.items.push declinedItem

            ctrl.moveItem item, ctrl.items

          it 'should move the item in the items array', ->
            expect(ctrl.items).toBe items
            newItems = []
            newItems.push
              isDivider: true
              title: ctrl.sections[Invitation.accepted].title
            newItems.push acceptedItem
            newItems.push
              isDivider: true
              title: ctrl.sections[Invitation.maybe].title
            itemCopy = angular.extend {}, item,
              isExpanded: false
              wasJoined: true
              wasUpdated: false
            newItems.push itemCopy
            newItems.push
              isDivider: true
              title: ctrl.sections[Invitation.declined].title
            newItems.push declinedItem
            expect(ctrl.items).toEqual newItems


        describe 'when there are no declined invitations', ->
          acceptedItem = null

          beforeEach ->
            ctrl.items.push
              isDivider: true
              title: ctrl.sections[Invitation.accepted].title
            acceptedItem = angular.extend
              isDivider: false
              wasJoined: true
              wasUpdated: false
            , noResponseInvitation,
              response: Invitation.accepted
              id: 7
            ctrl.items.push acceptedItem

            ctrl.moveItem item, ctrl.items

          it 'should move the item in the items array', ->
            expect(ctrl.items).toBe items
            newItems = []
            newItems.push
              isDivider: true
              title: ctrl.sections[Invitation.accepted].title
            newItems.push acceptedItem
            newItems.push
              isDivider: true
              title: ctrl.sections[Invitation.maybe].title
            itemCopy = angular.extend {}, item,
              isExpanded: false
              wasJoined: true
              wasUpdated: false
            newItems.push itemCopy
            expect(ctrl.items).toEqual newItems


      describe 'when the new response is declined', ->

        beforeEach ->
          item.response = Invitation.declined

          ctrl.moveItem item, ctrl.items

        it 'should move the item in the items array', ->
          expect(ctrl.items).toBe items
          newItems = []
          newItems.push
            isDivider: true
            title: ctrl.sections[Invitation.declined].title
          itemCopy = angular.extend {}, item,
            isExpanded: false
            wasUpdated: false
          newItems.push itemCopy
          expect(ctrl.items).toEqual newItems


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


  describe 'responding to an invitation', ->
    date = null
    $event = null
    deferred = null
    invitation = null
    response = null

    beforeEach ->
      jasmine.clock().install()
      date = new Date(1438014089235)
      jasmine.clock().mockDate date

      deferred = $q.defer()
      spyOn(Invitation, 'update').and.returnValue {$promise: deferred.promise}

      # Save the invitation before the item gets updated.
      invitation = angular.copy item
      for property in ['isDivider', 'wasJoined', 'wasUpdated']
        delete invitation[property]

      $event =
        stopPropagation: jasmine.createSpy '$event.stopPropagation'
      response = Invitation.accepted
      ctrl.respondToInvitation item, $event, response

    afterEach ->
      jasmine.clock().uninstall()

    it 'should stop the event from propagating', ->
      expect($event.stopPropagation).toHaveBeenCalled()

    it 'should update the invitation', ->
      invitation.response = response
      invitation.lastViewed = date
      expect(Invitation.update).toHaveBeenCalledWith invitation

    describe 'when the update succeeds', ->
      newResponse = null

      beforeEach ->
        spyOn ctrl, 'moveItem'

        newResponse = Invitation.accepted
        resolved = angular.extend {}, invitation, {response: newResponse}
        deferred.resolve resolved
        scope.$apply()

      it 'should set the new response on the item', ->
        expect(item.response).toBe newResponse

      it 'should move the item in the items array', ->
        expect(ctrl.moveItem).toHaveBeenCalledWith item, ctrl.items


    xdescribe 'when the update fails', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(item.respondError).toBe true

      describe 'then trying again', ->

        beforeEach ->
          ctrl.respondToInvitation item, $event, response

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
