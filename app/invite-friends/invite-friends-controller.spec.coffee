require '../ionic/ionic.js'
require 'angular'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require '../common/auth/auth-module'
require '../common/resources/resources-module'
InviteFriendsCtrl = require './invite-friends-controller'

describe 'invite friends controller', ->
  $controller = null
  $ionicHistory = null
  $ionicLoading = null
  $q = null
  $state = null
  $stateParams = null
  Auth = null
  ctrl = null
  event = null
  Event = null
  Invitation = null
  scope = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicHistory = $injector.get '$ionicHistory'
    $ionicLoading = $injector.get '$ionicLoading'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $stateParams = angular.copy $injector.get('$stateParams')
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

    spyOn $ionicHistory, 'nextViewOptions'

    spyOn(Auth, 'isNearby').and.callFake (friend) ->
      friend.id in [Auth.user.friends[2].id, Auth.user.friends[3].id]

    ctrl = $controller InviteFriendsCtrl,
      $scope: scope
      Auth: Auth
      $stateParams: $stateParams
  )

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  it 'should init the array of selected friends', ->
    expect(ctrl.selectedFriends).toEqual []

  it 'should init the dictionary of selected friend ids', ->
    expect(ctrl.selectedFriendIds).toEqual {}

  it 'should init the array of invited ids', ->
    expect(ctrl.invitedUserIds).toEqual {}

  describe 'when we\'re creating a new event', ->

    beforeEach ->
      # The event set on $stateParams doesn't have an id.
      ctrl = $controller InviteFriendsCtrl,
        $scope: scope
        Auth: Auth
        $stateParams: $stateParams
      scope.$broadcast '$ionicView.enter'
      scope.$apply()

    it 'should disable animating the transition to the next view', ->
      options = {disableAnimate: true}
      expect($ionicHistory.nextViewOptions).toHaveBeenCalledWith options


  describe 'when we\'re inviting users to an existing event', ->
    deferred = null
    respondedUserIds = null

    beforeEach ->
      # Mock event with an id.
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

      respondedUserIds = [999]
      $stateParams.respondedUserIds = respondedUserIds

      deferred = $q.defer()
      spyOn(Event, 'getInvitedIds').and.returnValue deferred.promise

      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'

      ctrl = $controller InviteFriendsCtrl,
        $scope: scope
        Auth: Auth
        $stateParams: $stateParams
      scope.$broadcast '$ionicView.enter'
      scope.$apply()

    it 'should set the member ids on the controller', ->
      expect(ctrl.respondedUserIds).toEqual respondedUserIds

    it 'should get invited ids', ->
      expect(Event.getInvitedIds).toHaveBeenCalledWith event

    it 'should show a loading indicator', ->
      expect($ionicLoading.show).toHaveBeenCalled()

    describe 'getting invited ids', ->

      describe 'when successful', ->
        invitedUserIds = null

        beforeEach ->
          spyOn(ctrl, 'buildItems').and.callThrough()

          invitedUserIds = [2]
          deferred.resolve invitedUserIds
          scope.$apply()

        it 'should hide the loading indicator', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'should set invited ids merged with respondedUserIds on controller', ->
          disabledIdsArray = invitedUserIds.concat respondedUserIds
          disabledIdsDict = {}
          for id in disabledIdsArray
            disabledIdsDict[id] = true
          expect(ctrl.invitedUserIds).toEqual disabledIdsDict

        it 'should call build items', ->
          expect(ctrl.buildItems).toHaveBeenCalled()


      describe 'when there is an error', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        xit 'should show an error', ->

        it 'should hide the loading indicator', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


  describe 'building the items array', ->

    beforeEach ->
      ctrl.buildItems()

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

    it 'should save a sorted array of nearby friends', ->
      expect(ctrl.nearbyFriends).toEqual  [ # Alphabetical
        Auth.user.friends[3]
        Auth.user.friends[2]
      ]

    it 'should save nearby friend ids', ->
      nearbyFriendIds = {}
      nearbyFriendIds[2] = true
      nearbyFriendIds[3] = true
      expect(ctrl.nearbyFriendIds).toEqual nearbyFriendIds


  describe 'toggling whether a friend is selected', ->
    friend = null

    beforeEach ->
      friend = Auth.user.friends[2]

    describe 'when the friend wasn\'t selected', ->

      beforeEach ->
        spyOn(ctrl, 'getWasSelected').and.returnValue false
        spyOn ctrl, 'selectFriend'

        ctrl.toggleSelected friend

      it 'should select the friend', ->
        expect(ctrl.selectFriend).toHaveBeenCalledWith friend


    describe 'when the friend has been selected', ->

      beforeEach ->
        spyOn(ctrl, 'getWasSelected').and.returnValue true
        ctrl.selectedFriends = [friend]
        ctrl.selectedFriendIds = {}
        ctrl.selectedFriendIds[friend.id] = true

        spyOn ctrl, 'deselectFriend'

        ctrl.toggleSelected friend

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
      spyOn(ctrl, 'getWasInvited').and.returnValue false

      friend = Auth.user.friends[2]
      ctrl.selectFriend friend

    it 'should add the friend to the array of selected friends', ->
      expect(ctrl.selectedFriends).toEqual [friend]

    it 'should add the friend to the dictionary of selected friend ids', ->
      selectedFriendIds = {}
      selectedFriendIds[friend.id] = true
      expect(ctrl.selectedFriendIds).toEqual selectedFriendIds

    it 'should check whether the friend was invited', ->
      expect(ctrl.getWasInvited).toHaveBeenCalledWith friend


  describe 'deselecting a friend', ->
    friend = null

    beforeEach ->
      friend = Auth.user.friends[2]
      ctrl.selectedFriends = [friend, Auth.user.friends[3]]
      ctrl.selectedFriendIds = {}
      ctrl.selectedFriendIds[friend.id] = true
      spyOn(ctrl, 'getWasInvited').and.returnValue false

    describe 'when the friend is a nearby friend', ->

      beforeEach ->
        ctrl.nearbyFriendIds = {}
        ctrl.nearbyFriendIds[friend.id] = true

        ctrl.deselectFriend friend

      it 'should remove the friend from the list of selected friends', ->
        expect(ctrl.selectedFriends).toEqual [Auth.user.friends[3]]

      it 'should remove the friend from the dictionary of selected friend ids', ->
        expect(ctrl.selectedFriendIds).toEqual {}

      it 'should check whether the friend was invited', ->
        expect(ctrl.getWasInvited).toHaveBeenCalledWith friend

      describe 'and all nearby friends is selected', ->

        beforeEach ->
          ctrl.isAllNearbyFriendsSelected = true

          ctrl.deselectFriend friend

        it 'should deselect all nearby friends', ->
          expect(ctrl.isAllNearbyFriendsSelected).toBe false


  describe 'sending the invitations', ->
    deferredCacheClear = null

    beforeEach ->
      ctrl.selectedFriends = [Auth.user.friends[2], Auth.user.friends[3]]

      deferredCacheClear = $q.defer()
      spyOn($ionicHistory, 'clearCache').and.returnValue \
          deferredCacheClear.promise

      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'

    describe 'when inviting to an existing event', ->
      deferredBulkCreate = null

      beforeEach ->
        deferredBulkCreate = $q.defer()
        spyOn(Invitation, 'bulkCreate').and.returnValue
          $promise: deferredBulkCreate.promise

        # The event id is set if we're inviting people to an existing event.
        ctrl.event.id = 1

        ctrl.sendInvitations()

      it 'should show a loading spinner', ->
        template = '''
          <div class="loading-text">Sending suggestion...</div>
          <ion-spinner icon="bubbles"></ion-spinner>
          '''
        expect($ionicLoading.show).toHaveBeenCalledWith {template: template}

      it 'should bulk create invitations', ->
        invitations = (Invitation.serialize {toUserId: friend.id} \
            for friend in ctrl.selectedFriends)
        expect(Invitation.bulkCreate).toHaveBeenCalledWith invitations


      describe 'successfully', ->

        beforeEach ->
          deferredBulkCreate.resolve()
          scope.$apply()

        it 'should clear the cache', ->
          expect($ionicHistory.clearCache).toHaveBeenCalled()

        describe 'when the cache is cleared', ->

          beforeEach ->
            spyOn $ionicHistory, 'goBack'

            deferredCacheClear.resolve()
            scope.$apply()

          it 'should go back to the event', ->
            expect($ionicHistory.goBack).toHaveBeenCalled()

          it 'should hide the loading indicator', ->
            expect($ionicLoading.hide).toHaveBeenCalled()


      describe 'unsuccessfully', ->

        beforeEach ->
          deferredBulkCreate.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ctrl.inviteError).toBe true

        it 'should hide the loading indicator', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


    describe 'when creating a new event', ->
      deferredEventSave = null
      newEvent = null

      beforeEach ->
        deferredEventSave = $q.defer()
        spyOn(Event, 'save').and.returnValue {$promise: deferredEventSave.promise}

        # Save the current version of the event.
        newEvent = angular.copy event

        ctrl.sendInvitations()

      it 'should show a loading spinner', ->
        expect($ionicLoading.show).toHaveBeenCalled()

      it 'should save the event', ->
        # Friend invitations
        invitations = (Invitation.serialize {toUserId: friend.id} \
            for friend in ctrl.selectedFriends)
        # The logged in user's invitation
        invitations.push Invitation.serialize
          toUserId: Auth.user.id
        newEvent.invitations = invitations
        expect(Event.save).toHaveBeenCalledWith newEvent

      describe 'successfully', ->

        beforeEach ->
          deferredEventSave.resolve()
          scope.$apply()

        it 'should clear the cache', ->
          expect($ionicHistory.clearCache).toHaveBeenCalled()

        describe 'when the cache is cleared', ->

          beforeEach ->
            spyOn $state, 'go'

            deferredCacheClear.resolve()
            scope.$apply()

          it 'should go to the events view', ->
            # TODO: Go to the events view before the save finishes.
            expect($state.go).toHaveBeenCalledWith 'events'

          it 'should hide the loading indicator', ->
            expect($ionicLoading.hide).toHaveBeenCalled()


      describe 'unsuccessfully', ->

        beforeEach ->
          deferredEventSave.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ctrl.inviteError).toBe true

        it 'should hide the loading indicator', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


  describe 'adding friends', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFriends()

    it 'should go to the add friends view', ->
      expect($state.go).toHaveBeenCalledWith 'addFriends'


  describe 'checking whether a user was selected', ->
    friend = null
    result = null

    beforeEach ->
      friend = Auth.user.friends[2]

    describe 'when the user was selected', ->

      beforeEach ->
        ctrl.selectedFriendIds = {}
        ctrl.selectedFriendIds[friend.id] = true

        result = ctrl.getWasSelected friend

      it 'should return true', ->
        expect(result).toBe true


    describe 'when the user wasn\'t selected', ->

      beforeEach ->
        ctrl.selectedFriendIds = {}

        result = ctrl.getWasSelected friend

      it 'should return false', ->
        expect(result).toBe false


  describe 'checking whether a user was invited', ->
    friend = null
    result = null

    beforeEach ->
      friend = Auth.user.friends[2]

    describe 'when they were invited', ->

      beforeEach ->
        ctrl.invitedUserIds = {}
        ctrl.invitedUserIds[friend.id] = true

        result = ctrl.getWasInvited friend

      it 'should return true', ->
        expect(result).toBe true


    describe 'when they weren\'t invited', ->

      beforeEach ->
        ctrl.invitedUserIds = {}

        result = ctrl.getWasInvited friend

      it 'should return false', ->
        expect(result).toBe false
