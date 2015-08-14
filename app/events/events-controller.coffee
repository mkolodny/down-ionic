class EventsCtrl
  constructor: (@$cordovaDatePicker, @$ionicModal, @$scope, @$state, @$timeout,
                @$window, @Asteroid, @dividerHeight, @eventHeight, @Invitation,
                @transitionDuration) ->
    # Save the section titles.
    @sections = {}
    @sections[@Invitation.noResponse] =
      title: 'New'
    @sections[@Invitation.accepted] =
      title: 'Down'
    @sections[@Invitation.maybe] =
      title: 'Maybe'
    @sections[@Invitation.declined] =
      title: 'Can\'t'

    # Init the set place modal.
    @$ionicModal.fromTemplateUrl 'app/set-place/set-place.html',
        scope: @$scope
        animation: 'slide-in-up'
      .then (modal) =>
        @setPlaceModal = modal

    # Set functions to control the place modal on the scope so that they can be
    # called from inside the modal.
    @$scope.hidePlaceModal = =>
      @setPlaceModal.hide()

    # Update the new event's place when the user selects a place.
    @$scope.$on 'placeAutocomplete:placeChanged', (event, place) =>
      @newEvent.hasPlace = true
      @newEvent.place =
        name: place.name
        lat: place.geometry.location.G
        long: place.geometry.location.K
      @$scope.hidePlaceModal()

    # Clean up the set place modal after hiding it.
    @$scope.$on '$destroy', =>
      @setPlaceModal.remove()

    @Invitation.getMyInvitations().then (invitations) =>
      # Save the invitations on the controller.
      @invitations = {}
      for invitation in invitations
        @invitations[invitation.id] = invitation

      # Build the list of items to show in the view.
      @items = @buildItems @invitations

      # Subscribe to the messages for each event.
      events = (invitation.event for invitation in invitations)
      @eventsMessagesSubscribe events
    , =>
      @getInvitationsError = true

  newEvent: {}

  toggleHasDate: ->
    if not @newEvent.hasDate
      options =
        mode: 'datetime'
        allowOldDates: false
        doneButtonLabel: 'Set Date'
      # If the user has set the date before, use the previous date they set.
      if angular.isDate(@newEvent.datetime)
        options.date = @newEvent.datetime
      else
        options.date = new Date()
      @$cordovaDatePicker.show options
        .then (date) =>
          if date?
            @newEvent.datetime = date
            @newEvent.hasDate = true
    else
      @newEvent.hasDate = false

  toggleHasPlace: ->
    if not @newEvent.hasPlace
      @setPlaceModal.show()
    else
      @newEvent.hasPlace = false

  toggleHasComment: ->
    if not @newEvent.hasComment
      @newEvent.hasComment = true
    else
      @newEvent.hasComment = false

  buildItems: (invitations) ->
    # Build the list of items to show on the view.
    items = []

    noResponseInvitations = (invitation for id, invitation of invitations \
        when invitation.response is @Invitation.noResponse)
    if noResponseInvitations.length > 0
      items.push
        isDivider: true
        title: @sections[@Invitation.noResponse].title
      for invitation in noResponseInvitations
        items.push angular.extend
          isDivider: false
          wasJoined: false
          wasUpdated: true
        , invitation

    for response in [@Invitation.accepted, @Invitation.maybe]
      title = @sections[response].title
      updatedInvitations = (invitation for id, invitation of invitations \
          when invitation.response is response \
          and invitation.lastViewed < invitation.event.updatedAt)
      oldInvitations = (invitation for id, invitation of invitations \
          when invitation.response is response \
          and invitation.lastViewed >= invitation.event.updatedAt)
      if updatedInvitations.length > 0 or oldInvitations.length > 0
        items.push
          isDivider: true
          title: title
        for invitation in updatedInvitations
          items.push angular.extend
            isDivider: false
            wasJoined: true
            wasUpdated: true
          , invitation
        for invitation in oldInvitations
          items.push angular.extend
            isDivider: false
            wasJoined: true
            wasUpdated: false
          , invitation

    declinedInvitations = (invitation for id, invitation of invitations \
        when invitation.response is @Invitation.declined)
    if declinedInvitations.length > 0
      items.push
        isDivider: true
        title: @sections[@Invitation.declined].title
      for invitation in declinedInvitations
        items.push angular.extend
          isDivider: false
          wasJoined: false
          wasUpdated: false
        , invitation

    # Give every item a top and a right property to allow for transitions.
    @setPositions items

    items

  setPositions: (items) ->
    top = 0
    for item in items
      item.top = top
      item.right = 0
      if item.isDivider
        top += @dividerHeight
      else
        top += @eventHeight

  eventsMessagesSubscribe: (events) ->
    # Subscribe to the messages posted in each event.
    for event in events
      @Asteroid.subscribe 'messages', event.id

    Messages = @Asteroid.getCollection 'messages'
    for event in events
      messagesRQ = Messages.reactiveQuery {eventId: event.id}

      # Set the latest message on the event.
      @setLatestMessage event, messagesRQ.result

      # Whenever a new message gets posted on the event, set the latest message
      # on the event.
      messagesRQ.on 'change', =>
        @setLatestMessage event, messagesRQ.result

  setLatestMessage: (event, messages) ->
    # Sort the messages from newest to oldest.
    messages.sort (a, b) ->
      if a.createdAt > b.createdAt
        return -1
      else
        return 1

    # Set the latest message on the event.
    latestMessage = messages[0]
    if latestMessage.type is 'text'
      event.latestMessage = "#{latestMessage.creator.name}: #{latestMessage.text}"
    else
      event.latestMessage = latestMessage.text

    # Update the event's updatedAt date.
    event.updatedAt = latestMessage.createdAt

    # Move the event's updated item.
    item = null
    for item in @items
      # TODO: item.invitation.event.id
      if !item.isDivider and item.event.id is event.id
        @moveItem item, @invitations

  moveItem: (item, invitations) ->
    @moving = true

    # Make sure the item is collapsed.
    item.isExpanded = false

    # Mark the item as currently being re-ordered.
    item.isReordering = true

    # Wait for the moving flag to be set on the view so that the list becomes
    # absolutely positioned.
    @$timeout =>
      newItems = @buildItems invitations

      # Update the top position of the current items in the DOM to match where
      # they'll be after we update the items.
      for newItem in newItems
        for oldItem in @items
          if (newItem.isDivider and newItem.title is oldItem.title) or \
              (not newItem.isDivider and newItem.id is oldItem.id)
            oldItem.top = newItem.top

      # Set the right position of items we'll be removing so that they're off the
      # screen.
      for oldItem in @items
        willBeRemoved = true
        # The item won't be removed if it's in the array of new items.
        for newItem in newItems
          if (newItem.isDivider and newItem.title is oldItem.title) or \
              (not newItem.isDivider and newItem.id is oldItem.id)
            willBeRemoved = false
        if willBeRemoved
          oldItem.right = @$window.innerWidth

      # After `transitionDuration` ms, replace the old items array with the new one.
      @$timeout =>
        @moving = false
        @items = newItems
      , @transitionDuration

  toggleIsExpanded: (item) ->
    item.isExpanded = not item.isExpanded

  acceptInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.accepted

  maybeInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.maybe

  declineInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.declined

  respondToInvitation: (item, $event, response) ->
    invitation = @invitations[item.id]

    # Prevent calling the ion-item element's ng-click.
    $event.stopPropagation()

    # Clear any previous errors.
    item.respondError = null

    invitation.response = response
    invitation.lastViewed = new Date()
    @Invitation.update(invitation).$promise.then (_invitation) =>
      @invitations[_invitation.id] = _invitation
      @moveItem item, @invitations
    , =>
      #item.respondError = true # Mock a successful response for now.

      @invitations[invitation.id] = invitation
      item.isExpanded = false
      item.isReordering = true
      @moveItem @invitations

  itemWasDeclined: (item) ->
    if item.response is @Invitation.declined
      return true

  inviteFriends: ->
    newEvent = @getNewEvent()
    @$state.go 'inviteFriends', {event: newEvent}

  getNewEvent: ->
    event = {title: @newEvent.title}
    if @newEvent.hasDate
      event.datetime = @newEvent.datetime
    if @newEvent.hasPlace
      event.place = @newEvent.place
    if @newEvent.hasComment
      event.comment = @newEvent.comment
    event

  myFriends: ->
    @$state.go 'friends'

module.exports = EventsCtrl
