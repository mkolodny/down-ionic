require 'angular'
require 'angular-mocks'
EventsCtrl = require './events-controller'

xdescribe 'find friends controller', ->
  $q = null
  ctrl = null
  deferred = null
  Invitation = null
  User = null
  scope = null

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    Auth = $injector.get 'Auth'
    Invitation = $injector.get 'Invitation'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    deferred = $q.defer()
    spyOn(Auth, 'getInvitations').and.returnValue deferred.promise

    ctrl = $controller EventsCtrl,
      $scope: scope
  )

  describe 'when the events request returns', ->

    describe 'successfully', ->
      noResponseInvitation = null
      acceptedInvitation = null
      updatedAcceptedInvitation = null
      maybeInvitation = null
      updatedMaybeInvitation = null
      declinedInvitation = null

      beforeEach ->
        lastViewed = new Date()
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
          lastViewed: lastViewed
          createdAt: new Date()
          updatedAt: new Date()
        laterDate = new Date(invitation.updatedAt.getTime()+1)
        noResponseInvitation = angular.extend {}, invitation,
          id: 2
          response: Invitation.noResponse
          event: angular.extend event,
            id: 2
        updatedAcceptedInvitation = angular.extend {}, invitation,
          id: 4
          response: Invitation.accepted
          event: angular.extend event,
            id: 4
          lastViewed: laterDate
        acceptedInvitation = angular.extend {}, invitation,
          id: 3
          response: Invitation.accepted
          event: angular.extend event,
            id: 3
        updatedMaybeInvitation = angular.extend {}, invitation,
          id: 6
          response: Invitation.maybe
          lastViewed: laterDate
          event: angular.extend event,
            id: 6
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
        deferred.resolve invitations
        scope.$apply()

      it 'should generate the items list', ->
        items = [
          isDivider: true
          title: 'New'
        ,
          angular.extend(noResponseInvitation, {isDivider: false})
        ,
          isDivider: true
          title: 'Down'
        ,
          angular.extend(updatedAcceptedInvitation, {isDivider: false})
        ,
          angular.extend(acceptedInvitation, {isDivider: false})
        ,
          isDivider: true
          title: 'Maybe'
        ,
          angular.extend(updatedMaybeInvitation, {isDivider: false})
        ,
          angular.extend(maybeInvitation, {isDivider: false})
        ,
          isDivider: true
          title: 'Can\'t'
        ,
          angular.extend(declinedInvitation, {isDivider: false})
        ]
        expect(ctrl.items).toEqual items

    describe 'with an error', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.getInvitationsError).toBe true
