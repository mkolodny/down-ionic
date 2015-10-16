require '../ionic/ionic.js' # for ionic module
require 'angular'
require 'angular-animate' # for ionic module
require 'angular-mocks'
require 'angular-sanitize' # for ionic module
require 'angular-ui-router'
require '../ionic/ionic-angular.js' # for ionic module
require 'ng-toast'
require '../common/auth/auth-module'
require '../common/meteor/meteor-mocks'
require './events-module'
EventsCtrl = require './events-controller'

describe 'events controller', ->
  $compile = null
  $httpBackend = null
  $ionicHistory = null
  $ionicPlatform = null
  $meteor = null
  $q = null
  $state = null
  $timeout = null
  $window = null
  Auth = null
  ctrl = null
  chatsCollection = null
  deferredGetInvitations = null
  deferredTemplate = null
  earlier = null
  Event = null
  Friendship = null
  friendSelectsCollection = null
  friendSelectsDeferred = null
  item = null
  invitation = null
  later = null
  Invitation = null
  matchesCollection = null
  messagesCollection = null
  newestMessagesDeferred = null
  ngToast = null
  scope = null
  User = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.events')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngToast')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $controller = $injector.get '$controller'
    $httpBackend = $injector.get '$httpBackend'
    $ionicHistory = $injector.get '$ionicHistory'
    $ionicPlatform = $injector.get '$ionicPlatform'
    $meteor = $injector.get '$meteor'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    $timeout = $injector.get '$timeout'
    $window = $injector.get '$window'
    Auth = angular.copy $injector.get 'Auth'
    Event = $injector.get 'Event'
    Friendship = $injector.get 'Friendship'
    Invitation = $injector.get 'Invitation'
    ngToast = $injector.get 'ngToast'
    scope = $rootScope.$new()
    User = $injector.get 'User'

    earlier = new Date()
    later = new Date earlier.getTime()+1
    invitation = new Invitation
      id: 1
      event: new Event
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
      fromUser: new User
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
      open: false
      muted: false
      lastViewed: later
      createdAt: new Date()
      updatedAt: new Date()
    item =
      isDivider: false
      invitation: invitation
      id: invitation.id

    # This is necessary because for some reason ionic is requesting this file
    # when the promise gets resolved.
    # TODO: Figure out why, and remove this.
    $httpBackend.whenGET 'app/events/events.html'
      .respond ''

    deferredGetInvitations = $q.defer()
    spyOn(Invitation, 'getMyInvitations').and.returnValue \
        deferredGetInvitations.promise
    spyOn $ionicPlatform, 'on'

    messagesCollection = 'messagesCollection'
    chatsCollection = 'chatsCollection'
    matchesCollection = 'matchesCollection'
    friendSelectsCollection = 'friendSelectsCollection'
    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'messages' then return messagesCollection
      if collectionName is 'chats' then return chatsCollection
      if collectionName is 'matches' then return matchesCollection
      if collectionName is 'friendSelects' then return friendSelectsCollection

    friendSelectsDeferred = $q.defer()
    newestMessagesDeferred = $q.defer()
    $meteor.subscribe.and.callFake (subscriptionName) =>
      if subscriptionName is 'friendSelects'
        return friendSelectsDeferred.promise
      if subscriptionName is 'newestMessages'
        return newestMessagesDeferred.promise

    ctrl = $controller EventsCtrl,
      $scope: scope
      Auth: Auth
  )

  it 'should init added me', ->
    expect(ctrl.addedMe).toEqual []

  it 'should listen for when the user comes back to the app', ->
    expect($ionicPlatform.on).toHaveBeenCalledWith 'resume', ctrl.manualRefresh

  it 'should set the messages collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'messages'
    expect(ctrl.Messages).toBe messagesCollection

  it 'should set the events collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'chats'
    expect(ctrl.Chats).toBe chatsCollection

  it 'should set the matches collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'matches'
    expect(ctrl.Matches).toBe matchesCollection

  it 'should set the friendSelects collection on the controller', ->
    expect(ctrl.FriendSelects).toBe friendSelectsCollection

  it 'should subscribe to the newestMessages', ->
    expect($meteor.subscribe).toHaveBeenCalledWith 'newestMessages'

  it 'should subscribe to friendSelects', ->
    expect($meteor.subscribe).toHaveBeenCalledWith 'friendSelects'

  it 'should init the invitations dict', ->
    expect(ctrl.invitations).toEqual {}

  describe 'when the friendSelects subscription is ready', ->
    newestMatch = null
    items = null

    beforeEach ->
      newestMatch =
        _id: 'asdkfjnasdlkfjn'
      spyOn(ctrl, 'getNewestMatch').and.returnValue newestMatch
      ctrl.invitations = 'invitations'
      items = 'items'
      spyOn(ctrl, 'buildItems').and.returnValue items

      friendSelectsDeferred.resolve()
      scope.$apply()

    it 'should bind the newestMatch to the controller', ->
      expect(ctrl.newestMatch).toBe newestMatch

    it 'should build the items list', ->
      expect(ctrl.buildItems).toHaveBeenCalledWith ctrl.invitations

    it 'should save the new items', ->
      expect(ctrl.items).toBe items

    describe 'when the newest match changes', ->

      beforeEach ->
        spyOn ctrl, 'handleNewMatch'
        ctrl.newestMatch.expiresAt = new Date()
        scope.$apply()

      it 'should handle the new match', ->
        expect(ctrl.handleNewMatch).toHaveBeenCalled()


  describe 'when the newestMessages subscription is ready', ->

    beforeEach ->
      newestMessagesDeferred.resolve()
      scope.$apply()

    it 'should subscribe to all messages', ->
      expect($meteor.subscribe).toHaveBeenCalledWith 'allMessages'


  # Only called once http://ionicframework.com/docs/api/directive/ionView/
  describe 'when the view is loaded', ->

    beforeEach ->
      spyOn ctrl, 'manualRefresh'

      scope.$broadcast '$ionicView.loaded'
      scope.$apply()

    it 'should refresh the items', ->
      expect(ctrl.manualRefresh).toHaveBeenCalled()


  describe 'when requesting events', ->
    refreshComplete = null

    beforeEach ->
      # Listen to the refresh complete event to check whether we've broadcasted
      # the event.
      refreshComplete = false
      scope.$on 'scroll.refreshComplete', ->
        refreshComplete = true

      ctrl.getInvitations()

    describe 'successfully', ->
      items = null
      percentRemaining = null
      response = null

      beforeEach ->
        items = []
        spyOn(ctrl, 'buildItems').and.returnValue items
        percentRemaining = 16
        spyOn(invitation.event, 'getPercentRemaining').and.returnValue \
            percentRemaining

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

      it 'should clear a loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should set the percent remaining on the event', ->
        expect(invitation.event.percentRemaining).toBe percentRemaining

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true


    describe 'with an error', ->

      beforeEach ->
        deferredGetInvitations.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.getInvitationsError).toBe true

      it 'should clear a loading flag', ->
        expect(ctrl.isLoading).toBe false

      it 'should stop the spinner', ->
        expect(refreshComplete).toBe true


  describe 'building the items list', ->
    acceptedInvitation = null
    maybeInvitation = null
    invitations = null
    olderMatch = null
    newerMatch = null
    matches = null
    friendWithUsername = null
    personWhoAddedMe = null
    builtItems = null
    newestMessage = null
    match = null
    friendSelect = null
    friendItems = null

    beforeEach ->
      # Mock the current user's id.
      Auth.user.id = 1

      # Mock invitations to events the user has joined.
      event = invitation.event
      olderTimestamp = 1
      newerTimestamp = 2
      acceptedInvitation = angular.extend {}, invitation,
        id: 2
        response: Invitation.accepted
        event: angular.extend {}, event,
          id: 2
          latestMessage:
            createdAt: newerTimestamp
      maybeInvitation = angular.extend {}, invitation,
        id: 3
        response: Invitation.maybe
        event: angular.extend {}, event,
          id: 3
          latestMessage:
            createdAt: olderTimestamp
      invitationsArray = [
        acceptedInvitation
        maybeInvitation
      ]
      invitations = {}
      for invitation in invitationsArray
        invitations[invitation.id] = invitation

      # Mock the user's friends.
      friendWithUsername =
        id: 2
        username: 'a$ap'
        name: 'A$AP Rocky'
        firstName: 'A$AP'
        lastName: 'Rocky'
        imageUrl: 'https://facebook.com/a$ap/pic'
      friendWithoutUsername =
        id: 3
        username: null
        name: 'Stephan Curry'
      friends = [friendWithUsername, friendWithoutUsername]
      Auth.user.friends = {}
      for friend in friends
        Auth.user.friends[friend.id] = friend
      # TODO: Sort the friends by latest message, then distance.

      # Mock the function to get the user's matches.
      olderMatch =
        _id: '1'
        firstUserId: "#{Auth.user.id}"
        secondUserId: "#{friendWithUsername.id}"
        expiresAt: olderTimestamp
      newerMatch =
        _id: '2'
        firstUserId: "#{friendWithoutUsername.id}"
        secondUserId: "#{Auth.user.id}"
        expiresAt: newerTimestamp
      matches = [olderMatch, newerMatch]
      spyOn(ctrl, 'getMatches').and.returnValue matches

      # Mock Person who added me
      personWhoAddedMe = new User
        id: 9
        username: 'pl$b'
        name: 'Mike Pleb'
        firstName: 'Mike'
        lastName: 'Pleb'
        imageUrl: 'https://numberonepleb.com/mike/pic'
      ctrl.addedMe = [personWhoAddedMe]

      newestMessage = 'newestMessage'
      spyOn(ctrl, 'getNewestMessage').and.returnValue newestMessage
      match = 'match'
      spyOn(ctrl, 'getMatch').and.returnValue match
      friendSelect = 'friendSelect'
      spyOn(ctrl, 'getFriendSelect').and.returnValue friendSelect

      friendItems = [
        isDivider: false
        friend: new User friendWithUsername
        id: friendWithUsername.id
        newestMessage: newestMessage
        friendSelect: friendSelect
      ]
      spyOn(ctrl, 'getFriendItems').and.returnValue friendItems

      builtItems = ctrl.buildItems invitations

    it 'should return the items', ->
      items = []

      # Events/matches section
      title = 'Happening'
      items.push
        isDivider: true
        title: title
        id: title
      # TODO: Handle when the user unfriended someone while they were still
      #   matched.
      items.push
        isDivider: false
        friend: Auth.user.friends[matches[0].secondUserId]
        id: matches[0]._id
        newestMessage: newestMessage
        match: match
        friendSelect: friendSelect
      items.push
        isDivider: false
        friend: Auth.user.friends[matches[1].firstUserId]
        id: matches[1]._id
        newestMessage: newestMessage
        match: match
        friendSelect: friendSelect
      for id, invitation of invitations
        items.push
          isDivider: false
          invitation: invitation
          id: invitation.id
          newestMessage: newestMessage

      # Friends section
      title = 'Friends'
      items.push
        isDivider: true
        title: title
        id: title
      items.push friendItems[0]

      # Added Me section
      title = 'Added Me'
      items.push
        isDivider: true
        title: title
        id: title
      items.push angular.extend
        isDivider: false
        friend: personWhoAddedMe
        id: personWhoAddedMe.id
        newestMessage: newestMessage
        friendSelect: friendSelect

      expect(builtItems).toEqual items


  describe 'getting friend items', ->
    newerMessage = null
    newerMessageFriend = null
    newerMessageFriendItem = null
    olderMessage = null
    olderMessageFriend = null
    olderMessageFriendItem = null
    nearerFriend = null
    nearerFriendItem = null
    fartherFriend = null
    fartherFriendItem = null
    stealthyFriend = null
    stealthyFriendItem = null
    returnedItems = null

    beforeEach ->
      # Mock the logged in user.
      Auth.user =
        id: 7
        friends: {}

      # Mock a friend without messages or a location.
      stealthyFriend =
        id: 1
        username: 'smitty'
      stealthyFriendItem =
        isDivider: false
        id: stealthyFriend.id
        friend: new User stealthyFriend
        newestMessage: {}
        friendSelect: stealthyFriend.id

      # Mock friends who have sent/received messages from the user.
      olderTimestamp = 1
      olderMessage =
        _id: '1'
        createdAt: olderTimestamp
      olderMessageFriend =
        id: 2
        username: 'bignick'
      olderMessageFriendItem =
        isDivider: false
        id: olderMessageFriend.id
        friend: new User olderMessageFriend
        newestMessage: olderMessage
        friendSelect: olderMessageFriend.id
      newerTimestamp = 2
      newerMessage =
        _id: '2'
        createdAt: newerTimestamp
      newerMessageFriend =
        id: 3
        username: 'drock'
      newerMessageFriendItem =
        isDivider: false
        id: newerMessageFriend.id
        friend: new User newerMessageFriend
        newestMessage: newerMessage
        friendSelect: newerMessageFriend.id

      # Mock friends who haven't sent/received messages, but have a location.
      fartherFriend =
        id: 5
        username: 'kb'
        location:
          lat: 40.7286954
          long: -74.0069337
      fartherFriendItem =
        isDivider: false
        id: fartherFriend.id
        friend: new User fartherFriend
        newestMessage: {}
        friendSelect: fartherFriend.id
      nearerFriend =
        id: 6
        username: 'kost'
        location:
          lat: 40.7194731
          long: -73.9957201
      nearerFriendItem =
        isDivider: false
        id: nearerFriend.id
        friend: new User nearerFriend
        newestMessage: {}
        friendSelect: nearerFriend.id

      # Mock a friend without a username.
      friendWithoutUsername =
        id: 8
        username: null

      spyOn(Friendship, 'getChatId').and.callFake (id) -> id
      spyOn(ctrl, 'getFriendSelect').and.callFake (id) -> id
      spyOn(ctrl, 'getNewestMessage').and.callFake (chatId) ->
        if chatId is newerMessageFriend.id
          newerMessage
        else if chatId is olderMessageFriend.id
          olderMessage
        else
          {}

    describe 'when both friends have messages', ->

      beforeEach ->
        friends =  [newerMessageFriend, olderMessageFriend]
        for friend in friends
          Auth.user.friends[friend.id] = friend

        returnedItems = ctrl.getFriendItems()

      it 'should return the items sorted from newer to older messages', ->
        items = [newerMessageFriendItem, olderMessageFriendItem]
        expect(returnedItems).toEqual items


    describe 'when only the first friend has a message', ->

      beforeEach ->
        friends =  [olderMessageFriend, stealthyFriend]
        for friend in friends
          Auth.user.friends[friend.id] = friend

        returnedItems = ctrl.getFriendItems()

      it 'should return the item with a message first', ->
        items = [olderMessageFriendItem, stealthyFriendItem]
        expect(returnedItems).toEqual items


    describe 'when the user has a location', ->

      beforeEach ->
        Auth.user.location =
          lat: 40.7138251
          long: -73.9897481

      describe 'and both friends have a location', ->

        beforeEach ->
          friends = [fartherFriend, nearerFriend]
          for friend in friends
            Auth.user.friends[friend.id] = friend

          returnedItems = ctrl.getFriendItems()

        it 'should return the nearer friend before the farther one', ->
          items = [nearerFriendItem, fartherFriendItem]
          expect(returnedItems).toEqual items


      describe 'and only one friend has a location', ->

        beforeEach ->
          friends = [fartherFriend, stealthyFriend]
          for friend in friends
            Auth.user.friends[friend.id] = friend

          returnedItems = ctrl.getFriendItems()

        it 'should return the friend with a location before the one without', ->
          items = [fartherFriendItem, stealthyFriendItem]
          expect(returnedItems).toEqual items


  describe 'getting the newest message', ->
    chatId = null
    meteorObject = null
    result = null

    beforeEach ->
      chatId = "3"
      meteorObject = 'meteorObject'
      scope.$meteorObject = jasmine.createSpy('scope.$meteorObject')
        .and.returnValue meteorObject
      result = ctrl.getNewestMessage chatId

    it 'should return an AngularMeteorObject', ->
      expect(result).toBe meteorObject

    it 'should query, sort and transform the message', ->
      selector =
        chatId: chatId
      options =
        sort:
          createdAt: -1
        transform: ctrl.transformMessage
      expect(scope.$meteorObject).toHaveBeenCalledWith(ctrl.Messages, selector,
          false, options)


  describe 'transforming a message', ->

    describe 'when the message is of type text', ->
      message = null
      result = null
      chat = null

      beforeEach ->
        chat = 'chat'
        scope.$meteorObject = jasmine.createSpy('scope.$meteorObject')
          .and.returnValue chat

        message =
          type: 'text'
          text: 'Hi Guys!'
          creator:
            firstName: 'Jimbo'

        result = ctrl.transformMessage angular.copy(message)

      it 'should update the message text', ->
        expectedText = "#{message.creator.firstName}: #{message.text}"
        expect(result.text).toEqual expectedText

      it 'should bind the chat to the message', ->
        expect(result.chat).toEqual chat


  describe 'checking if a message was read', ->

    describe 'when message the data has\'t loaded yet', ->
      result = null

      beforeEach ->
        result = ctrl.wasRead undefined

      it 'should default to true', ->
        expect(result).toBe true


    describe 'when a message has been read', ->
      message = null
      result = null

      beforeEach ->
        Auth.user =
          id: 1
        message =
          createdAt: new Date 10
          chat:
            members: [
              userId: "1",
              lastRead: new Date 1000
            ]

        result = ctrl.wasRead message

      it 'should return true', ->
        expect(result).toBe true


    describe 'when a message has not been read', ->
      message = null
      result = null

      beforeEach ->
        Auth.user =
          id: 1
        message =
          createdAt: new Date 1000
          chat:
            members: [
              userId: "1",
              lastRead: new Date 10
            ]

        result = ctrl.wasRead message

      it 'should return false', ->
        expect(result).toBe false


  describe 'getting the friendSelect', ->
    friendId = null
    meteorObject = null
    response = null

    beforeEach ->
      meteorObject = 'meteorObject'
      scope.$meteorObject = jasmine.createSpy('scope.$meteorObject') \
        .and.returnValue meteorObject
      friendId = 1
      response = ctrl.getFriendSelect friendId

    it 'should return an AngularMeteorObject', ->
      expect(response).toBe meteorObject

    it 'should filter by friendId and add a tranform for time remaining', ->
      selector =
        friendId: "#{friendId}"
      options =
        transform: ctrl.addPercentRemaining
      expect(scope.$meteorObject).toHaveBeenCalledWith(ctrl.FriendSelects,
          selector, false, options)


  describe 'transforming the friendSelect', ->
    sixHours = null
    threeHours = null
    result = null
    friendSelect = null

    beforeEach ->
      jasmine.clock().install()
      date = new Date 1438014089235
      jasmine.clock().mockDate date

      sixHours = 1000 * 60 * 60 * 6
      threeHours = 1000 * 60 * 60 * 3

      friendSelect =
        _id: 'asdfasdf'
        expiresAt: new Date(new Date().getTime() + threeHours)

      result = ctrl.addPercentRemaining angular.copy(friendSelect)

    afterEach ->
      jasmine.clock().uninstall()

    it 'should set the percent remaining', ->
      friendSelect.percentRemaining = 50
      expect(result).toEqual friendSelect


  describe 'getting the newest match', ->
    meteorObject = null
    response = null

    beforeEach ->
      meteorObject = 'meteorObject'
      scope.$meteorObject = jasmine.createSpy('scope.$meteorObject') \
        .and.returnValue meteorObject
      response = ctrl.getNewestMatch()

    it 'should return an AngularMeteorObject', ->
      expect(response).toBe meteorObject

    it 'should filter by friendId', ->
      options =
        sort:
          expiresAt: -1
      expect(scope.$meteorObject).toHaveBeenCalledWith(ctrl.Matches, {}, false,
          options)


  describe 'handling the new match', ->
    friendId = null
    friend = null
    items = null

    beforeEach ->
      friendId = 1
      friend =
        id: friendId
        name: 'Jim Bob'
      Auth.user =
        id: 2
        friends: {}
      Auth.user.friends[friendId] = friend

      ctrl.newestMatch =
        firstUserId: "#{friendId}"
        secondUserId: "#{Auth.user.id}"
      spyOn $state, 'go'
      ctrl.invitations = 'invitations'
      items = 'items'
      spyOn(ctrl, 'buildItems').and.returnValue items

      ctrl.handleNewMatch()

    it 'should transition to the chat', ->
      expect($state.go).toHaveBeenCalledWith 'friendship',
        friend: friend
        id: friendId

    it 'should build the items list', ->
      expect(ctrl.buildItems).toHaveBeenCalledWith ctrl.invitations

    it 'should save the new items', ->
      expect(ctrl.items).toBe items


  describe 'getting the user\'s matches', ->
    meteorCollection = null
    matches = null

    beforeEach ->
      ctrl.Matches = 'Matches'
      meteorCollection = 'meteorCollection'
      scope.$meteorCollection = jasmine.createSpy('scope.$meteorCollection') \
        .and.returnValue meteorCollection

      matches = ctrl.getMatches()

    it 'should fetch the matches from mongo', ->
      expect(scope.$meteorCollection).toHaveBeenCalledWith ctrl.Matches, false

    it 'should return the meteorCollection', ->
      expect(matches).toBe meteorCollection


  describe 'getting people who added me', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Auth, 'getAddedMe').and.returnValue {$promise: deferred.promise}

      ctrl.getAddedMe()

    it 'should get the people who added me', ->
      expect(Auth.getAddedMe).toHaveBeenCalled()

    describe 'when the request returns successfully', ->
      user = null
      users = null

      beforeEach ->
        spyOn ctrl, 'buildItems'

        user =
          id: 3
        users = [user]
        deferred.resolve users
        scope.$apply()

      it 'should set the people who added me on the controller', ->
        expect(ctrl.addedMe).toBe users

      it 'should rebuild the items', ->
        expect(ctrl.buildItems).toHaveBeenCalled()


  describe 'manually refreshing', ->

    beforeEach ->
      ctrl.isLoading = false
      spyOn ctrl, 'getInvitations'
      spyOn ctrl, 'getAddedMe'

      ctrl.manualRefresh()

    it 'should set a loading flag', ->
      expect(ctrl.isLoading).toBe true

    it 'should get the invitations', ->
      expect(ctrl.getInvitations).toHaveBeenCalled()

    it 'should get people who added me', ->
      expect(ctrl.getAddedMe).toHaveBeenCalled()


  describe 'ionic\'s pull to refresh', ->

    beforeEach ->
      spyOn ctrl, 'getInvitations'
      spyOn ctrl, 'getAddedMe'

      ctrl.refresh()

    it 'should get the invitations', ->
      expect(ctrl.getInvitations).toHaveBeenCalled()

    it 'should get people who added me', ->
      expect(ctrl.getAddedMe).toHaveBeenCalled()


  describe 'viewing an event chat', ->
    invitation = null

    beforeEach ->
      spyOn $state, 'go'
      invitation =
        event:
          id: 1
      item =
        invitation: invitation
      ctrl.viewEventChat item

    it 'should go to the event chat', ->
      expect($state.go).toHaveBeenCalledWith 'event',
        invitation: invitation
        id: invitation.event.id


  describe 'viewing an friend chat', ->
    friend = null

    beforeEach ->
      spyOn $state, 'go'
      friend =
        id: 1
      item =
        friend: friend
      ctrl.viewFriendChat item

    it 'should go to the friend chat', ->
      expect($state.go).toHaveBeenCalledWith 'friendship',
        friend: friend
        id: item.friend.id


  describe 'tapping to add by username', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addByUsername()

    it 'should go to the add by username view', ->
      expect($state.go).toHaveBeenCalledWith 'addByUsername'


  describe 'tapping to add from address book', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromAddressBook()

    it 'should go to the add from address book view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromAddressBook'


  describe 'tapping to add from facebook', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromFacebook()

    it 'should go to the add from facebook view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromFacebook'


  describe 'checking how far away a friend is', ->
    distanceAway = null
    friend = null
    returnedDistanceAway = null

    describe 'when distance can be calculated', ->

      beforeEach ->
        distanceAway = 'distanceAway'
        spyOn(Auth, 'getDistanceAway').and.returnValue distanceAway
        friend =
          id: 2
          location:
            lat: 40.7138251
            long: -73.9897481

        returnedDistanceAway = ctrl.getDistanceAway friend

      it 'should check how far away they are', ->
        expect(Auth.getDistanceAway).toHaveBeenCalledWith friend.location

      it 'should return the distance away', ->
        expect(returnedDistanceAway).toBe "#{distanceAway} away"

    describe 'when distance is unknown', ->

      beforeEach ->
        spyOn(Auth, 'getDistanceAway').and.returnValue null
        friend =
          id: 2
        returnedDistanceAway = ctrl.getDistanceAway friend

      it 'should show the default message', ->
        expect(returnedDistanceAway).toBe 'Start a chat...'


  describe 'before the view enters', ->
    friend = null

    beforeEach ->
      friend =
        id: 1

    describe 'when the friends list hasn\'t been saved', ->

      beforeEach ->
        delete ctrl.friendsList
        Auth.user.friends = {}
        Auth.user.friends[friend.id] = friend

        scope.$emit '$ionicView.beforeEnter'
        scope.$apply()

      it 'should save the friends list', ->
        friendsList = {}
        friendsList[friend.id] = true
        expect(ctrl.friendsList).toEqual friendsList


    describe 'when the friends list has changed', ->

      beforeEach ->
        ctrl.friendsList = {}
        ctrl.friendsList[friend.id+1] = true
        spyOn ctrl, 'manualRefresh'

        scope.$emit '$ionicView.beforeEnter'
        scope.$apply()

      it 'should refresh the feed', ->
        expect(ctrl.manualRefresh).toHaveBeenCalled()

      it 'should save the new friends list', ->
        friendsList = {}
        friendsList[friend.id] = true
        expect(ctrl.friendsList).toEqual friendsList


  describe 'viewing the friends view', ->

    beforeEach ->
      spyOn $ionicHistory, 'nextViewOptions'
      spyOn $state, 'go'

      ctrl.myFriends()

    it 'should disable the transition animation', ->
      expect($ionicHistory.nextViewOptions).toHaveBeenCalledWith
        disableAnimate: true

    it 'should go to the friends view', ->
      expect($state.go).toHaveBeenCalledWith 'friends'


  describe 'creating an event', ->

    beforeEach ->
      spyOn $ionicHistory, 'nextViewOptions'
      spyOn $state, 'go'

      ctrl.createEvent()

    it 'should disable the transition animation', ->
      expect($ionicHistory.nextViewOptions).toHaveBeenCalledWith
        disableAnimate: true

    it 'should go to the create event view', ->
      expect($state.go).toHaveBeenCalledWith 'createEvent'


  describe 'toggling whether a friend is selected', ->
    item = null
    friend = null
    friendSelect = null
    $event = null

    beforeEach ->
      friend =
        id: 1
      friendSelect =
        _id: 'asdf'
      item =
        friend: friend
        friendSelect: friendSelect
      $event =
        stopPropagation: jasmine.createSpy '$event.stopPropagation'
      ctrl.FriendSelects =
        remove: jasmine.createSpy 'FriendSelects.remove'
        insert: jasmine.createSpy 'FriendSelects.insert'

    describe 'when they are selected', ->

      beforeEach ->
        spyOn(ctrl, 'isSelected').and.returnValue true

        ctrl.toggleIsSelected item, $event

      it 'should check if the friend is selected', ->
        expect(ctrl.isSelected).toHaveBeenCalledWith item

      it 'should prevent the default event', ->
        expect($event.stopPropagation).toHaveBeenCalled()

      it 'should remove the selectFriend object', ->
        expect(ctrl.FriendSelects.remove).toHaveBeenCalledWith
          _id: friendSelect._id


    describe 'when they aren\'t selected', ->
      userId = null

      beforeEach ->
        spyOn(ctrl, 'isSelected').and.returnValue false
        userId = 1
        Auth.user.id = userId

        jasmine.clock().install()
        date = new Date 1438014089235
        jasmine.clock().mockDate date

        ctrl.toggleIsSelected item, $event

      afterEach ->
        jasmine.clock().uninstall()

      it 'should check if the friend is selected', ->
        expect(ctrl.isSelected).toHaveBeenCalledWith item

      it 'should prevent the default event', ->
        expect($event.stopPropagation).toHaveBeenCalled()

      it 'should insert a friend select', ->
        now = new Date().getTime()
        sixHours = 1000 * 60 * 60 * 6
        sixHoursFromNow = new Date(now + sixHours)
        expect(ctrl.FriendSelects.insert).toHaveBeenCalledWith
          userId: "#{userId}"
          friendId: "#{friend.id}"
          expiresAt: sixHoursFromNow


  describe 'checking whether a friend is selected', ->
    item = null

    describe 'when they are selected', ->

      beforeEach ->
       item =
          friendSelect:
            _id: 'asdfas'

      it 'should return true', ->
        expect(ctrl.isSelected(item)).toBe true


    describe 'when they aren\'t selected', ->

      beforeEach ->
        item =
          friendSelect: {}

      it 'should return false', ->
        expect(ctrl.isSelected(item)).toBe false


  describe 'getting a match', ->
    friendId = null
    meteorObject = null
    response = null

    beforeEach ->
      meteorObject = 'meteorObject'
      scope.$meteorObject = jasmine.createSpy('scope.$meteorObject') \
        .and.returnValue meteorObject
      friendId = 1
      response = ctrl.getMatch friendId

    it 'should return an AngularMeteorObject', ->
      expect(response).toBe meteorObject

    it 'should filter by friendId and add a tranform for time remaining', ->
      selector =
        $or: [
          firstUserId: "#{friendId}"
        ,
          secondUserId: "#{friendId}"
        ]
      options =
        transform: ctrl.addPercentRemaining
      expect(scope.$meteorObject).toHaveBeenCalledWith(ctrl.Matches,
          selector, false, options)
