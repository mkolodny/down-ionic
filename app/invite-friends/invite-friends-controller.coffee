class InviteFriendsCtrl
  constructor: (@$ionicHistory, @$ionicLoading, @$state, @$stateParams,
                 @Auth, @Event, @Invitation) ->
    @event = @$stateParams.event
    @memberIds = @$stateParams.memberIds or []
    @selectedFriends = []
    @selectedFriendIds = {}
    @invitedIds = []

    if @event.id?
      # Inviting to an existing event
      @$ionicLoading.show
        template: '''
          <ion-spinner icon="bubbles"></ion-spinner>
        '''
      @Event.getInvitedIds(@event).then (invitedIds) =>
        # Member ids are for friends that were invited by another
        #   friend and have already responded down or maybe
        @invitedIds = invitedIds.concat @memberIds
        @buildItems()
      .finally =>
        @$ionicLoading.hide()
    else
      # Creating a new event
      @$ionicHistory.nextViewOptions
        disableAnimate: true
      @buildItems()

  buildItems: ->
    # Make a copy of the user's friends so that when the user selects the friend in
    #   one section, they get selected in every section.
    # TODO: Handle when the user's friends aren't set on auth yet.
    friends = angular.copy @Auth.user.friends

    # Build the list of alphabetically sorted nearby friends.
    @nearbyFriends = (friend for id, friend of friends when @Auth.isNearby(friend))
    @nearbyFriends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1

    # Set isInvited for all friends who are already members of the event
    for userId in @invitedIds
      friend = friends[userId]
      if friend?
        friend.isInvited = true

    # Build the list of alphabetically sorted items.
    friends = (friend for id, friend of friends)
    friends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1
    alphabeticalItems = []
    currentLetter = null
    for friend in friends
      if friend.name[0] != currentLetter
        alphabeticalItems.push
          isDivider: true
          title: friend.name[0]
        currentLetter = friend.name[0]

      alphabeticalItems.push
        isDivider: false
        friend: friend

    # Build the list of items to show in the collection.
    @items = []
    if @nearbyFriends.length > 0
      @items.push
        isDivider: true
        title: 'Nearby Friends'
    for friend in @nearbyFriends
      @items.push
        isDivider: false
        friend: friend
    for item in alphabeticalItems
      @items.push item


  toggleIsSelected: (friend) ->
    if not friend.isSelected
      @selectFriend friend
    else
      @deselectFriend friend

  toggleAllNearbyFriends: ->
    if not @isAllNearbyFriendsSelected
      @isAllNearbyFriendsSelected = true
      for friend in @nearbyFriends
        if not @selectedFriendIds[friend.id]
          @selectFriend friend
    else
      @isAllNearbyFriendsSelected = false
      for friend in @nearbyFriends
        @deselectFriend friend

  selectFriend: (friend) ->
    # Ignore if friend in @invitedIds
    if friend.isInvited then return null

    friend.isSelected = true
    @selectedFriends.push friend
    @selectedFriendIds[friend.id] = true

  deselectFriend: (friend) ->
    # Ignore if friend in @invitedIds
    if friend.isInvited then return null

    # Deselect the all nearby friends toggle if the friend is nearby.
    if @isAllNearbyFriendsSelected
      isNearby = false
      for friend in @selectedFriends
        if friend is friend
          isNearby = true
      if isNearby
        @isAllNearbyFriendsSelected = false

    friend.isSelected = false
    @selectedFriends = (_friend for _friend in @selectedFriends \
        when _friend isnt friend)
    delete @selectedFriendIds[friend.id]

  sendInvitations: ->
    # Create the user's friends' invitations.
    invitations = (@Invitation.serialize {toUserId: friend.id} \
        for friend in @selectedFriends)

    # TODO : if event has an id, bulk create invitations

    # Create the user's invitation.
    invitations.push @Invitation.serialize
      toUserId: @Auth.user.id
    @event.invitations = invitations
    @Event.save @event
      .$promise.then =>
        @$ionicHistory.clearCache()
      .then =>
        @$state.go 'events'
      , =>
        @inviteError = true

  addFriends: ->
    @$state.go 'addFriends'

module.exports = InviteFriendsCtrl
