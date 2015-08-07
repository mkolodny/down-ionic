class InviteFriendsCtrl
  constructor: (@$state, @$stateParams, @Auth, @Event, @Invitation) ->
    # Make a copy of the user's friends so that when the user selects the friend in
    # one section, they get selected in every section.
    friends = angular.copy @Auth.friends

    @event = @$stateParams.event
    @selectedFriends = []
    @selectedFriendIds = {}

    # Mock friends for now.
    friend1 =
      id: 1
      name: 'Michael Kolodny'
    friend2 =
      id: 2
      name: 'Andrew Linfoot'
    @nearbyFriends = [friend1]
    alphabeticalItems = [
      isDivider: true
      title: 'A'
    ,
      isDivider: false
      friend: friend2
    ,
      isDivider: true
      title: 'M'
    ,
      isDivider: false
      friend: friend1
    ]

    ###
    # Build the list of alphabetically sorted nearby friends.
    @nearbyFriends = (friend for id, friend of friends when @Auth.isNearby(friend))
    @nearbyFriends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1

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
    ###

    # Build the list of items to show in the collection.
    @items = []
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
    friend.isSelected = true
    @selectedFriends.push friend
    @selectedFriendIds[friend.id] = true

  deselectFriend: (friend) ->
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
    invitations = []
    # Create the user's friends' invitations.
    for friend in @selectedFriends
      invitations.push
        fromUser: @Auth.user.id
        toUser: friend.id
        response: @Invitation.noResponse
    # Create the user's invitation.
    invitations.push
      fromUser: @Auth.user.id
      toUser: @Auth.user.id
      response: @Invitation.maybe
    @event.invitations = invitations
    @Event.save @event
      .$promise.then =>
        @$state.go 'events'
      , =>
        @inviteError = true

module.exports = InviteFriendsCtrl
