class EventsCtrl
  @$inject: ['$cordovaDatePicker', '$ionicHistory', '$ionicLoading',
             '$ionicPlatform', '$meteor', '$scope', '$state', '$timeout', 'Auth',
             'Friendship', 'Invitation', 'ngToast', 'User']
  constructor: (@$cordovaDatePicker, @$ionicHistory, @$ionicLoading,
                @$ionicPlatform, @$meteor, @$scope, @$state, @$timeout, @Auth,
                @Friendship, @Invitation, @ngToast, @User) ->
    # Set Meteor collections on controller
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'
    @Matches = @$meteor.getCollectionByName 'matches'
    @FriendSelects = @$meteor.getCollectionByName 'friendSelects'

    # Subscribe to friendSelects data
    @$meteor.subscribe('friendSelects').then =>
      @newestMatch = @getNewestMatch()
      # Watch for new matches
      @$scope.$watch =>
        @newestMatch.expiresAt
      , (newValue, oldValue) =>
        # First cycle, old and new
        #   value will be equal
        if newValue isnt oldValue
          @handleNewMatch()

    # Init the view.
    @addedMe = []

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
    @$ionicPlatform.on 'resume', @manualRefresh

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
    if invitations.length > 0
      title = 'Plans'
      items.push
        isDivider: true
        title: title
        id: title
      for invitation in invitations
        items.push angular.extend
          isDivider: false
          invitation: invitation
          id: invitation.id
          # DON'T SET THE METEOR ANGULAR VARIABLES ON THE EVENT ITSELF!!
          #   AngularMeteorObject.getRawObject() breaks... not sure why...
          #   When passing an AngularMeteorObject into $state.go, AngularMeteor.getRawObject()
          #   is automatically called. Therefore, do not pass AngularMeteorObjects into $state.go.
          newestMessage: @getNewestMessage "#{invitation.event.id}"

    # Friends section
    friends = (friend for id, friend of @Auth.user.friends \
        when friend.username isnt null)

    if friends.length > 0
      title = 'Friends'
      items.push
        isDivider: true
        title: title
        id: title
      for friend in friends
        chatId = @Friendship.getChatId friend.id
        @$scope.$meteorSubscribe 'chat', chatId
        items.push angular.extend
          isDivider: false
          friend: new @User friend
          id: friend.id
          newestMessage: @getNewestMessage chatId
          friendSelect: @getFriendSelect friend.id

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

  eventsMessagesSubscribe: (events) ->
    # Subscribe to the messages posted in each event.
    for event in events
      @$scope.$meteorSubscribe 'chat', "#{event.id}"

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
        transform: @transformFriendSelect
    @$scope.$meteorObject @FriendSelects, selector, false, options

  transformFriendSelect: (friendSelect) =>
    now = new Date().getTime()
    timeRemaining = friendSelect.expiresAt.getTime() - now
    sixHours = 1000 * 60 * 60 * 6
    friendSelect.percentRemaining = (timeRemaining / sixHours) * 100
    friendSelect

  getNewestMatch: =>
    @$scope.$meteorObject @Matches, {}, false,
      sort:
        expiresAt: -1

  handleNewMatch: =>
    # If second user in match, go into chat
    if @newestMatch.secondUserId is "#{@Auth.user.id}"
      friendId = parseInt @newestMatch.firstUserId
      @$state.go 'friendship',
        friend: @Auth.user.friends[friendId]
        id: friendId

  #   # Move the event's updated item.
  #   for item in @items
  #     if item.invitation?.event.id is event.id
  #       @items = @buildItems @invitations

  acceptInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.accepted

  maybeInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.maybe

  declineInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.declined

  respondToInvitation: (item, $event, response) ->
    # Prevent calling the ion-item element's ng-click.
    $event.stopPropagation()

    invitation = @invitations[item.invitation.id]
    @Invitation.updateResponse invitation, response
      .$promise.then null, =>
        @items = @buildItems @invitations
        @ngToast.create 'For some reason, that didn\'t work.'

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

        # Subscribe to the messages for each event.
        events = (invitation.event for invitation in invitations)
        @eventsMessagesSubscribe events

        # Set `percentRemaining` as a property on each event as a workaround for
        #   stopping angular-chart.js from calling `getPercentRemaining` too many
        #   times.
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
        for user in addedMe
          chatId = @Friendship.getChatId user.id
          @$scope.$meteorSubscribe 'chat', chatId

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

    if @isSelected(item)
      # Remove friend select
      @FriendSelects.remove {_id: item.friendSelect._id}
    else
      now = new Date().getTime()
      sixHours = 1000 * 60 * 60 * 6
      sixHoursFromNow = new Date(now + sixHours)
      # Create new friendSelect
      @FriendSelects.insert
        userId: "#{@Auth.user.id}"
        friendId: "#{item.friend.id}"
        expiresAt: sixHoursFromNow

  isSelected: (item) ->
    angular.isDefined item.friendSelect._id

module.exports = EventsCtrl
