require 'angular'
require 'angular-mocks'
require '../common/auth/auth-module'
require '../common/resources/resources-module'
InviteFriendsCtrl = require './invite-friends-controller'

describe 'invite friends controller', ->
  $q = null
  $state = null
  Auth = null
  ctrl = null
  event = null
  Event = null
  Invitation = null
  scope = null

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $stateParams = $injector.get '$stateParams'
    Auth = angular.copy $injector.get('Auth')
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'
    scope = $rootScope.$new()

    # Mock the logged in user.
    Auth.user =
      id: 1
      email: 'aturing@gmail.com'
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535

    # Mock the user's friends.
    Auth.user.friends =
      2:
        id: 2
        email: 'ltorvalds@gmail.com'
        name: 'Linus Torvalds'
        username: 'valding'
        imageUrl: 'https://facebook.com/profile-pics/valding'
        location:
          lat: 40.7265834 # just under 5 mi away
          long: -73.9821535
      3:
        id: 3
        email: 'jclarke@gmail.com'
        name: 'Joan Clarke'
        username: 'jnasty'
        imageUrl: 'https://facebook.com/profile-pics/jnasty'
        location:
          lat: 40.7265834 # just under 5 mi away
          long: -73.9821535
      4:
        id: 4
        email: 'gvrossum@gmail.com'
        name: 'Guido van Rossum'
        username: 'vrawesome'
        imageUrl: 'https://facebook.com/profile-pics/vrawesome'
        location:
          lat: 40.79893 # just over 5 mi away
          long: -73.9821535

    # Mock the event being created.
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
    $stateParams.event = event

    spyOn(Auth, 'isNearby').and.callFake (friend) ->
      friend.id in [Auth.user.friends[2].id, Auth.user.friends[3].id]

    ctrl = $controller InviteFriendsCtrl,
      $scope: scope
      Auth: Auth
      $stateParams: $stateParams
  )

  it 'should init the array of selected friends', ->
    expect(ctrl.selectedFriends).toEqual []

  it 'should init the dictionary of selected friend ids', ->
    expect(ctrl.selectedFriendIds).toEqual {}

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  xdescribe 'getting the array of nearby friends', ->

    it 'should be a sorted array of nearby friends', ->
      expect(ctrl.nearbyFriends).toEqual  [ # Alphabetical
        Auth.user.friends[3]
        Auth.user.friends[2]
      ]


  xdescribe 'getting the array of items', ->

    it 'should be an array of nearby friends then alphabetical friends', ->
      items = [
        isDivider: true
        title: 'Nearby Friends'
      ]
      for friend in ctrl.nearbyFriends
        items.push
          isDivider: false
          friend: friend
      alphabeticalItems = [
        isDivider: true
        title: Auth.user.friends[4].name[0]
      ,
        isDivider: false
        friend: Auth.user.friends[4]
      ,
        isDivider: true
        title: Auth.user.friends[3].name[0]
      ,
        isDivider: false
        friend: Auth.user.friends[3]
      ,
        isDivider: true
        title: Auth.user.friends[2].name[0]
      ,
        isDivider: false
        friend: Auth.user.friends[2]
      ]
      for item in alphabeticalItems
        items.push item
      expect(ctrl.items).toEqual items


  describe 'toggling whether a friend is selected', ->
    friend = null

    beforeEach ->
      friend = Auth.user.friends[2]

    describe 'when the friend isn\'t selected', ->

      beforeEach ->
        spyOn ctrl, 'selectFriend'

        ctrl.toggleIsSelected friend

      it 'should select the friend', ->
        expect(ctrl.selectFriend).toHaveBeenCalledWith friend


    describe 'when the friend has been selected', ->

      beforeEach ->
        friend.isSelected = true
        ctrl.selectedFriends = [friend]
        ctrl.selectedFriendIds = {}
        ctrl.selectedFriendIds[friend.id] = true

        spyOn ctrl, 'deselectFriend'

        ctrl.toggleIsSelected friend

      it 'should deselect the friend', ->
        expect(ctrl.deselectFriend).toHaveBeenCalledWith friend


  describe 'toggling all nearby friends', ->

    describe 'when all nearby friends hasn\'t been selected', ->

      beforeEach ->
        ctrl.nearbyFriends = [Auth.user.friends[2], Auth.user.friends[3]]
        ctrl.selectedFriendIds = {}
        ctrl.selectedFriendIds[Auth.user.friends[3].id] = true

        spyOn ctrl, 'selectFriend'

        ctrl.toggleAllNearbyFriends()

      it 'should select the nearby friends item', ->
        expect(ctrl.isAllNearbyFriendsSelected).toBe true

      it 'should select each friend in the list of nearby friends', ->
        expect(ctrl.selectFriend).toHaveBeenCalledWith Auth.user.friends[2]


    describe 'when all nearby friends is selected', ->

      beforeEach ->
        ctrl.isAllNearbyFriendsSelected = true
        ctrl.nearbyFriends = [Auth.user.friends[2], Auth.user.friends[3]]

        spyOn ctrl, 'deselectFriend'

        ctrl.toggleAllNearbyFriends()

      it 'should deselect the nearby friends item', ->
        expect(ctrl.isAllNearbyFriendsSelected).toBe false

      it 'should deselect each friend in the list of nearby friends', ->
        for friend in ctrl.nearbyFriends
          expect(ctrl.deselectFriend).toHaveBeenCalledWith friend


  describe 'selecting a friend', ->
    friend = null

    beforeEach ->
      ctrl.selectedFriends = []
      ctrl.selectedFriendIds = {}

      friend = Auth.user.friends[2]
      ctrl.selectFriend friend

    it 'should set the friend to selected', ->
      expect(friend.isSelected).toBe true

    it 'should add the friend to the array of selected friends', ->
      expect(ctrl.selectedFriends).toEqual [friend]

    it 'should add the friend to the dictionary of selected friend ids', ->
      selectedFriendIds = {}
      selectedFriendIds[friend.id] = true
      expect(ctrl.selectedFriendIds).toEqual selectedFriendIds


  describe 'deselecting a friend', ->
    friend = null

    beforeEach ->
      friend = Auth.user.friends[2]
      ctrl.selectedFriends = [friend, Auth.user.friends[3]]
      ctrl.selectedFriendIds = {}
      ctrl.selectedFriendIds[friend.id] = true
      friend.isSelected = true

    describe 'when the friend is a nearby friend', ->

      beforeEach ->
        ctrl.deselectFriend friend

      it 'should set the friend to not selected', ->
        expect(friend.isSelected).toBe false

      it 'should remove the friend from the list of selected friends', ->
        expect(ctrl.selectedFriends).toEqual [Auth.user.friends[3]]

      it 'should remove the friend from the dictionary of selected friend ids', ->
        expect(ctrl.selectedFriendIds).toEqual {}


    describe 'when the friend is a nearby friend', ->

      beforeEach ->
        ctrl.nearbyFriends = [friend]

      describe 'and all nearby friends is selected', ->

        beforeEach ->
          ctrl.isAllNearbyFriendsSelected = true

          ctrl.deselectFriend friend

        it 'should deselect all nearby friends', ->
          expect(ctrl.isAllNearbyFriendsSelected).toBe false


  describe 'sending the invitations', ->
    deferred = null
    newEvent = null

    beforeEach ->
      ctrl.selectedFriends = [Auth.user.friends[2], Auth.user.friends[3]]

      deferred = $q.defer()
      spyOn(Event, 'save').and.returnValue {$promise: deferred.promise}

      # Save the current version of the event.
      newEvent = angular.copy event

      ctrl.sendInvitations()

    it 'should save the event', ->
      invitations = []
      # Friend invitations
      for friend in ctrl.selectedFriends
        invitations.push
          fromUser: Auth.user.id
          toUser: friend.id
          response: Invitation.noResponse
      # The logged in user's invitation
      invitations.push
        fromUser: Auth.user.id
        toUser: Auth.user.id
        response: Invitation.maybe
      newEvent.invitations = invitations
      expect(Event.save).toHaveBeenCalledWith newEvent

    describe 'successfully', ->

      beforeEach ->
        spyOn $state, 'go'

        deferred.resolve()
        scope.$apply()

      it 'should go to the events view', ->
        # TODO: Go to the events view before the save finishes.
        expect($state.go).toHaveBeenCalledWith 'events'


    describe 'unsuccessfully', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.inviteError).toBe true
