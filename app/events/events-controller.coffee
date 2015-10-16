haversine = require 'haversine'

class EventsCtrl
  @$inject: ['$cordovaDatePicker', '$ionicHistory', '$ionicLoading',
             '$ionicPlatform', '$meteor', '$mixpanel', '$scope', '$state', '$timeout', 'Auth',
             'Friendship', 'Invitation', 'ngToast', 'User']
  constructor: (@$cordovaDatePicker, @$ionicHistory, @$ionicLoading,
                @$ionicPlatform, @$meteor, @$mixpanel, @$scope, @$state, @$timeout, @Auth,
                @Friendship, @Invitation, @ngToast, @User) ->
    # Init the view.
    @addedMe = []
    @invitations = {}

    # Set Meteor collections on controller
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'
    @Matches = @$meteor.getCollectionByName 'matches'
    @FriendSelects = @$meteor.getCollectionByName 'friendSelects'

    # Subscribe to friendSelects data
    @$meteor.subscribe('friendSelects').then =>
      @newestMatch = @getNewestMatch()
      @items = @buildItems @invitations

      # Watch for new matches
      @$scope.$watch =>
        @newestMatch.expiresAt
      , (newValue, oldValue) =>
        # First cycle, old and new
        #   value will be equal
        if newValue isnt oldValue
          @handleNewMatch()

    # Subscribe to chat latest messages
    @$meteor.subscribe('newestMessages').then =>
      @$meteor.subscribe 'allMessages'

    @$scope.$on '$ionicView.loaded', =>
      # Fetch the invitations to show on the view.
      @manualRefresh()

    @$scope.$on '$ionicView.beforeEnter', =>
      # If the user's friends list has changed since they last entered this
      #   view, refresh the feed.
      friendsList = {}
      for id, friend of @Auth.user.friends
        friendsList[id] = true

      if angular.isDefined(@friendsList) \
          and not angular.equals(friendsList, @friendsList)
        @manualRefresh()

      @friendsList = friendsList

    # Refresh the feed when the user comes back to the app.
    #@$ionicPlatform.on 'resume', @manualRefresh

  buildItems: (invitationsDict) ->
    # Build the list of items to show on the view.
    items = []

    # Invitations Section
    invitations = (invitation for id, invitation of invitationsDict)
    invitations.sort (a, b) ->
      aCreatedAt = a.event.latestMessage?.createdAt or a.event.createdAt
      bCreatedAt = b.event.latestMessage?.createdAt or b.event.createdAt
      if aCreatedAt > bCreatedAt
        return -1
      else
        return 1
    matches = @getMatches()
    if invitations.length > 0 or matches.length > 0
      title = 'Happening'
      items.push
        isDivider: true
        title: title
        id: title
      for match in matches
        firstUserId = parseInt match.firstUserId
        secondUserId = parseInt match.secondUserId
        if @Auth.user.id is firstUserId
          friend = @Auth.user.friends[secondUserId]
        else
          friend = @Auth.user.friends[firstUserId]
        chatId = @Friendship.getChatId friend.id
        items.push
          isDivider: false
          friend: friend
          id: match._id
          newestMessage: @getNewestMessage chatId
          match: @getMatch friend.id
          friendSelect: @getFriendSelect friend.id
      for invitation in invitations
        items.push
          isDivider: false
          invitation: invitation
          id: invitation.id
          # DON'T SET THE METEOR ANGULAR VARIABLES ON THE EVENT ITSELF!!
          #   AngularMeteorObject.getRawObject() breaks... not sure why...
          #   When passing an AngularMeteorObject into $state.go,
          #   AngularMeteor.getRawObject() is automatically called. Therefore, do
          #   not pass AngularMeteorObjects into $state.go.
          newestMessage: @getNewestMessage "#{invitation.event.id}"

    # Friends section
    friendItems = @getFriendItems()
    if friendItems.length > 0
      title = 'Friends'
      items.push
        isDivider: true
        title: title
        id: title
      for item in friendItems
        items.push item

    # Added me section
    if @addedMe.length > 0
      title = 'Added Me'
      items.push
        isDivider: true
        title: title
        id: title
      for user in @addedMe
        chatId = @Friendship.getChatId user.id
        items.push angular.extend
          isDivider: false
          friend: user
          id: user.id
          newestMessage: @getNewestMessage chatId
          friendSelect: @getFriendSelect user.id

    items

  getFriendItems: ->
    friends = (friend for id, friend of @Auth.user.friends \
        when friend.username isnt null)

    # Build an unsorted list of items.
    items = []
    for friend in friends
      chatId = @Friendship.getChatId friend.id
      items.push angular.extend
        isDivider: false
        friend: new @User friend
        id: friend.id
        newestMessage: @getNewestMessage chatId
        friendSelect: @getFriendSelect friend.id

    # Get the user's location to check which friend is nearer.
    userHasLocation = angular.isDefined @Auth.user.location
    if userHasLocation
      userLocation =
        latitude: @Auth.user.location.lat
        longitude: @Auth.user.location.long

    items.sort (a, b) ->
      aHasMessage = angular.isDefined a.newestMessage._id
      bHasMessage = angular.isDefined b.newestMessage._id
      if aHasMessage and bHasMessage
        if a.newestMessage.createdAt > b.newestMessage.createdAt
          return -1
        else if a.newestMessage.createdAt < b.newestMessage.createdAt
          return 1
        else
          return 0
      else if aHasMessage # only a has a message
        return -1
      else if bHasMessage # only b has a message
        return 1

      if not userHasLocation
        return 0

      aHasLocation = angular.isDefined a.friend.location
      bHasLocation = angular.isDefined b.friend.location
      if aHasLocation and bHasLocation # and userHasLocation
        aLocation =
          latitude: a.friend.location.lat
          longitude: a.friend.location.long
        bLocation =
          latitude: b.friend.location.lat
          longitude: b.friend.location.long
        distanceToA = haversine userLocation, aLocation
        distanceToB = haversine userLocation, bLocation
        if distanceToA < distanceToB
          return -1
        else if distanceToA > distanceToB
          return 1
        else
          return 0
      else if aHasLocation # only a has a location
        return -1
      else if bHasLocation # only b has a location
        return 1

      0 # Neither user has a message or location

    items

  getNewestMessage: (chatId) =>
    selector =
      chatId: chatId
    options =
      sort:
        createdAt: -1
      transform: @transformMessage
    @$scope.$meteorObject @Messages, selector, false, options

  transformMessage: (message) =>
    # Show senders first name
    if message.type is 'text'
      firstName = message.creator.firstName
      message.text = "#{firstName}: #{message.text}"

    # Bind chat for checking wasRead
    message.chat = @$scope.$meteorObject @Chats, {chatId: message.chatId}, false

    message

  wasRead: (message) =>
    # Default to read to stop flicker
    if message?.chat is undefined then return true

    members = message.chat?.members or []
    lastRead = (member.lastRead for member in members \
        when "#{@Auth.user.id}" is member.userId)[0]
    lastRead >= message.createdAt

  getFriendSelect: (friendId) =>
    selector =
      friendId: "#{friendId}"
    options =
      transform: @addPercentRemaining
    @$scope.$meteorObject @FriendSelects, selector, false, options

  getMatch: (friendId) =>
    selector =
      $or: [
        firstUserId: "#{friendId}"
      ,
        secondUserId: "#{friendId}"
      ]
    options =
      transform: @addPercentRemaining
    @$scope.$meteorObject @Matches, selector, false, options

  addPercentRemaining: (obj) =>
    now = new Date().getTime()
    timeRemaining = obj.expiresAt.getTime() - now
    sixHours = 1000 * 60 * 60 * 6
    obj.percentRemaining = (timeRemaining / sixHours) * 100
    obj

  getMatches: ->
    @$scope.$meteorCollection @Matches, false

  getNewestMatch: =>
    @$scope.$meteorObject @Matches, {}, false,
      sort:
        expiresAt: -1

  handleNewMatch: =>
    # If second user in match, go into chat
    isSecondUser = @newestMatch.secondUserId is "#{@Auth.user.id}"
    if isSecondUser
      friendId = parseInt @newestMatch.firstUserId
      @$state.go 'friendship',
        friend: @Auth.user.friends[friendId]
        id: friendId

    @$mixpanel.track 'Match Friend',
      'is second user': isSecondUser

    # Re-build the items list.
    @items = @buildItems @invitations

  inviteFriends: ->
    # Don't animate the transition to the invite friends view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

    @$state.go 'friends'

  createEvent: ->
    # Don't animate the transition to the create event view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

    @$state.go 'createEvent'

  myFriends: ->
    # Don't animate the transition to the create event view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

    @$state.go 'friends'

  viewEventChat: (item) ->
    @$state.go 'event',
      invitation: item.invitation
      id: item.invitation.event.id

  viewFriendChat: (item) ->
    @$state.go 'friendship',
      friend: item.friend
      id: item.friend.id

  getInvitations: ->
    @Invitation.getMyInvitations()
      .then (invitations) =>
        # Save the invitations on the controller.
        @invitations = {}
        for invitation in invitations
          @invitations[invitation.id] = invitation

        # Build the list of items to show in the view.
        @items = @buildItems @invitations

        # Set `percentRemaining` as a property on each event as a workaround for
        #   stopping angular-chart.js from calling `getPercentRemaining` too many
        #   times.
        events = (invitation.event for invitation in invitations)
        for event in events
          event.percentRemaining = event.getPercentRemaining()
      , =>
        @getInvitationsError = true
      .finally =>
        @$scope.$broadcast 'scroll.refreshComplete'
        @isLoading = false

  getAddedMe: ->
    @Auth.getAddedMe()
      .$promise.then (addedMe) =>
        @addedMe = addedMe
        @buildItems()

  refresh: ->
    @getInvitations()
    @getAddedMe()

  manualRefresh: =>
    @isLoading = true
    @getInvitations()
    @getAddedMe()

  addByUsername: ->
    @$state.go 'addByUsername'

  addFromAddressBook: ->
    @$state.go 'addFromAddressBook'

  addFromFacebook: ->
    @$state.go 'addFromFacebook'

  getDistanceAway: (friend) ->
    distanceAway = @Auth.getDistanceAway friend.location
    if distanceAway is null
      'Start a chat...'
    else
      "#{distanceAway} away"

  toggleIsSelected: (item, $event) ->
    $event.stopPropagation()

    if @isSelected item
      # Remove friend select
      @FriendSelects.remove {_id: item.friendSelect._id}
      @$mixpanel.track 'Deselect Friend'
    else
      now = new Date().getTime()
      sixHours = 1000 * 60 * 60 * 6
      sixHoursFromNow = new Date now + sixHours
      # Create new friendSelect
      @FriendSelects.insert
        userId: "#{@Auth.user.id}"
        friendId: "#{item.friend.id}"
        expiresAt: sixHoursFromNow
      @$mixpanel.track 'Select Friend'

  isSelected: (item) ->
    angular.isDefined item.friendSelect._id

module.exports = EventsCtrl
