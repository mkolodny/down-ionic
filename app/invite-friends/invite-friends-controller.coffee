class InviteFriendsCtrl
  @$inject: ['$ionicHistory', '$ionicLoading', '$scope', '$state', 'Auth',
             'Event', 'Invitation', 'localStorageService']
  constructor: (@$ionicHistory, @$ionicLoading, @$scope, @$state, @Auth, @Event,
                @Invitation, localStorageService) ->
    @localStorage = localStorageService

    @selectedFriends = []
    @selectedFriendIds = {}
    @invitedUserIds = {}

    @$scope.$on '$ionicView.enter', =>
      # use existing event if not set on state params
      #   i.e. coming back from add friends
      # NOTE : use @$state.params instead of @$stateParams
      #   because https://github.com/driftyco/ionic/issues/3884
      @event = @$state.params.event or @event

      # Clear previous errors
      @error = false

      # Default to calling cleanupView after leaving
      #   addFriends overwrites this
      @cleanupViewAfterLeave = true

      # Don't animate the transition to the next view.
      @$ionicHistory.nextViewOptions
        disableAnimate: true

      if 'id' of @event
        # We're inviting more people to an existing event.
        @$ionicLoading.show()

        @Event.getInvitedIds(@event)
          .then (invitedUserIds) =>
            for id in invitedUserIds
              @invitedUserIds[id] = true
            @buildItems()
          , =>
            @error = 'getInvitedIdsError'
          .finally =>
            @$ionicLoading.hide()
      else
        # We're creating a new event.
        @buildItems()

    @$scope.$on '$ionicView.afterLeave', =>
      if @cleanupViewAfterLeave
        @cleanupView()

  cleanupView: ->
    delete @event
    @selectedFriends = []
    @selectedFriendIds = {}
    @invitedUserIds = {}

  buildItems: ->
    # Build the list of alphabetically sorted nearby friends.
    @nearbyFriends = (friend for id, friend of @Auth.user.friends \
      when @Auth.isNearby friend)
    @nearbyFriends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1

    # Save nearby friends' ids.
    @nearbyFriendIds = {}
    for nearbyFriend in @nearbyFriends
      @nearbyFriendIds[nearbyFriend.id] = true

    # Build the list of alphabetically sorted items.
    friends = (friend for id, friend of @Auth.user.friends)
    friends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1
    alphabeticalItems = []
    currentLetter = null
    for friend in friends
      if angular.isDefined @nearbyFriendIds[friend.id]
        continue

      if friend.name[0] != currentLetter
        alphabeticalItems.push
          isDivider: true
          title: friend.name[0]
        currentLetter = friend.name[0]

      alphabeticalItems.push
        isDivider: false
        friend: friend

    # Build the list of facebook friends.
    facebookFriends = (friend for id, friend of @Auth.user.facebookFriends \
        when @Auth.user.friends[id] is undefined)
    facebookFriends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1
    facebookFriendsItems = ({isDivider: false, friend: friend} \
        for friend in facebookFriends)

    # Build the list of contacts.
    contacts = (contact for id, contact of @localStorage.get 'contacts')
    contacts.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1
    contactsItems = ({isDivider: false, friend: friend} \
        for friend in contacts \
        when @Auth.user.friends[friend.id] is undefined \
        and @Auth.user.facebookFriends[friend.id] is undefined)

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
    if facebookFriendsItems.length > 0
      @items.push
        isDivider: true
        title: 'Facebook Friends'
    for item in facebookFriendsItems
      @items.push item
    if contactsItems.length > 0
      @items.push
        isDivider: true
        title: 'Contacts'
    for item in contactsItems
      @items.push item

    # Give each item an id so that we can use `track by` to improve performance.
    for item in @items
      if item.isDivider
        item.id = item.title
      else
        item.id = item.friend.id

  toggleSelected: (friend) ->
    if @getWasSelected friend
      @deselectFriend friend
    else
      @selectFriend friend

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
    # Don't do anything if the friend was already invited.
    if @getWasInvited friend
      return

    @selectedFriends.push friend
    @selectedFriendIds[friend.id] = true

  deselectFriend: (friend) ->
    # Don't do anything if the friend was already invited.
    if @getWasInvited friend
      return

    # Deselect the all nearby friends toggle if the friend is nearby.
    if @isAllNearbyFriendsSelected
      if @nearbyFriendIds[friend.id]
        @isAllNearbyFriendsSelected = false

    @selectedFriends = (_friend for _friend in @selectedFriends \
        when _friend.id isnt friend.id)
    delete @selectedFriendIds[friend.id]

  sendInvitations: ->
    @$ionicLoading.show
      template: '''
        <div class="loading-text">
          Sending suggestion...
        </div>
        <ion-spinner icon="bubbles"></ion-spinner>
        '''

    if 'id' of @event
      # Invite more people to an existing event.
      invitations = ({toUserId: friend.id} \
            for friend in @selectedFriends)
      eventId = @event.id

      @Invitation.bulkCreate eventId, invitations
        .then =>
          @$ionicHistory.clearCache()
        .then =>
          @cleanupView()
          @$ionicHistory.goBack()
        , =>
          @error = 'inviteError'
        .finally =>
          @$ionicLoading.hide()
    else
      ## Create a new event.

      # Create the user's friends' invitations.
      invitations = (@Invitation.serialize {toUserId: friend.id} \
          for friend in @selectedFriends)

      # Create the current user's invitation.
      invitations.push @Invitation.serialize
        toUserId: @Auth.user.id

      @event.invitations = invitations
      @Event.save @event
        .$promise.then =>
          @$ionicHistory.clearCache()
        .then =>
          @cleanupView()
          @$state.go 'events'
        , =>
          @error = 'inviteError'
        .finally =>
          @$ionicLoading.hide()

  addFriends: ->
    @cleanupViewAfterLeave = false
    @$state.go 'addFriends'

  getWasSelected: (friend) ->
    @selectedFriendIds[friend.id] is true

  getWasInvited: (friend) ->
    @invitedUserIds[friend.id] is true

  search: (item) =>
    if not @query
      return true

    if item.isDivider
      return false

    item.friend.name.toLowerCase().indexOf(@query.toLowerCase()) isnt -1

module.exports = InviteFriendsCtrl
