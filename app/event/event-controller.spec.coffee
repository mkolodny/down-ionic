require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/resources/resources-module'
EventCtrl = require './event-controller'

describe 'events controller', ->
  $q = null
  $state = null
  ctrl = null
  deferred = null
  event = null
  invitation = null
  Invitation = null
  scope = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('ui.router')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $stateParams = $injector.get '$stateParams'
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

    deferred = $q.defer()
    spyOn(Invitation, 'getEventInvitations').and.returnValue
      $promise: deferred.promise

    ctrl = $controller EventCtrl
  )

  it 'should set the user\'s invitation on the controller', ->
    expect(ctrl.invitation).toBe invitation

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  it 'should request the event members\' invitations', ->
    expect(Invitation.getEventInvitations).toHaveBeenCalledWith {id: event.id}

  describe 'when the invitations return successfully', ->
    invitations = null

    beforeEach ->
      invitations = [invitation]
      deferred.resolve invitations
      scope.$apply()

    xit 'should set the invitations on the controller', ->
      members = (invitation.toUser for invitation in invitations)
      expect(ctrl.members).toEqual members


  describe 'when the invitations return unsuccessfully', ->

    beforeEach ->
      deferred.reject()
      scope.$apply()

    xit 'should show an error', ->
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
