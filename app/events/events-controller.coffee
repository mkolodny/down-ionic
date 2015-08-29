class EventsCtrl
  constructor: (@$cordovaDatePicker, @$ionicHistory, @$ionicModal, @$scope, @$state,
                @$timeout, @$window, @Asteroid, @dividerHeight, @eventHeight,
                @Invitation, @transitionDuration, @Auth) ->
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

    # Fetch the invitations to show on the view.
    @isLoading = true
    @getInvitations()

    @newEvent = {}

  toggleHasDate: ->
    if not @newEvent.hasDate
      options =
        mode: 'datetime' # This can be anything other than 'date' or 'time'
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
          invitation: invitation

    for response in [@Invitation.accepted, @Invitation.maybe]
      title = @sections[response].title
      updatedInvitations = (invitation for id, invitation of invitations \
          when invitation.response is response)
      oldInvitations = []
      # TODO: Check whether the user has read the event's most recent message.
      ###
          and invitation.lastViewed < invitation.event.updatedAt)
      oldInvitations = (invitation for id, invitation of invitations \
          when invitation.response is response \
          and invitation.lastViewed >= invitation.event.updatedAt)
      ###
      if updatedInvitations.length > 0 or oldInvitations.length > 0
        items.push
          isDivider: true
          title: title
        for invitation in updatedInvitations
          items.push angular.extend
            isDivider: false
            wasJoined: true
            wasUpdated: true
            invitation: invitation
        for invitation in oldInvitations
          items.push angular.extend
            isDivider: false
            wasJoined: true
            wasUpdated: false
            invitation: invitation

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
          invitation: invitation

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
      messagesRQ = Messages.reactiveQuery {eventId: "#{event.id}" } # Meteor likes strings

      # Keep the same value of `messagesRQ` even after the variable changes
      #   next time through the loop.
      do (event, messagesRQ) =>
        # Set the latest message on the event.
        messages = angular.copy messagesRQ.result
        @setLatestMessage event, messages

        # Whenever a new message gets posted on the event, set the latest message
        # on the event.
        messagesRQ.on 'change', (_id) =>
          messages = angular.copy messagesRQ.result
          if @isNewMessage event, _id
            @setLatestMessage event, messages

  # mongo _id's are randomly generated client side via
  # Asteroid and therefore are not chronological
  # use the message.createdAt for determining new messages
  isNewMessage: (event, messageId) ->
    # latest message hasn't been set yet
    if not event.latestMessage? then return true

    # get message object by _id
    Messages = @Asteroid.getCollection 'messages'
    messagesRQ = Messages.reactiveQuery {_id: messageId}
    message = messagesRQ.result[0]
    message.createdAt.$date > event.updatedAt.getTime()

  setLatestMessage: (event, messages) ->
    if messages.length is 0 then return

    # Sort the messages from newest to oldest.
    messages.sort (a, b) ->
      if a.createdAt.$date > b.createdAt.$date
        return -1
      else
        return 1

    # Set the latest message text on the event.
    latestMessage = messages[0]
    if latestMessage.type is 'text'
      firstName = latestMessage.creator.firstName
      event.latestMessageText = "#{firstName}: #{latestMessage.text}"
    else
      event.latestMessageText = latestMessage.text

    # Set unread or not for message
    event.latestMessageIsUnread = @isUnreadMessage latestMessage

    # Only update the event if the latest message is newer than the updatedAt.
    if latestMessage.createdAt.$date <= event.updatedAt.getTime()
      return

    # Update the event's updatedAt date.
    event.updatedAt = new Date(latestMessage.createdAt.$date)

    # Move the event's updated item.
    item = null
    for item in @items
      if item.invitation?.event.id is event.id
        @moveItem item, @invitations

  isUnreadMessage: (message) ->
    Events = @Asteroid.getCollection 'events'
    eventsRQ = Events.reactiveQuery {_id: message.eventId}
    event = eventsRQ.result[0]
    # Have to check if event exists in case the 
    # subscribe hasn't returned the event yet
    if event?
      member = (member for member in event.members \
        when member.userId is @Auth.user.id)
      lastRead = member[0].lastRead

      if lastRead.$date < message.createdAt.$date
        return true
    return false

  moveItem: (item, invitations) ->
    # TODO: If none of the items are going to move, just return.

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
          if @areItemsEqual(newItem, oldItem)
            oldItem.top = newItem.top

      # Set the right position of items we'll be removing so that they're off the
      # screen.
      for oldItem in @items
        willBeRemoved = true
        # The item won't be removed if it's in the array of new items.
        for newItem in newItems
          if @areItemsEqual(newItem, oldItem)
            willBeRemoved = false
        if willBeRemoved
          oldItem.right = @$window.innerWidth

      # After `transitionDuration` ms, replace the old items array with the new one.
      @$timeout =>
        @moving = false
        @items = newItems
      , @transitionDuration

  areItemsEqual: (item1, item2) ->
    if item1.isDivider and item2.isDivider
      item1.title is item2.title
    else if item1.invitation? and item2.invitation?
      item1.invitation.id is item2.invitation.id
    else
      false

  toggleIsExpanded: (item) ->
    item.isExpanded = not item.isExpanded

  acceptInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.accepted

  maybeInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.maybe

  declineInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.declined

  respondToInvitation: (item, $event, response) ->
    invitation = @invitations[item.invitation.id]

    # Prevent calling the ion-item element's ng-click.
    $event.stopPropagation()

    # Clear any previous errors.
    item.respondError = null

    @Invitation.updateResponse invitation, response
      .$promise.then null, =>
        @moveItem item, @invitations
        item.respondError = true

    @moveItem item, @invitations

  itemWasDeclined: (item) ->
    item.invitation.response is @Invitation.declined

  inviteFriends: ->
    # Don't animate the transition to the invite friends view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

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
    # Don't animate the transition to the invite friends view.
    @$ionicHistory.nextViewOptions
      disableAnimate: true

    @$state.go 'friends'

  viewEvent: (item) ->
    @$state.go 'event',
      invitation: item.invitation
      id: item.invitation.event.id

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

  refresh: ->
    @getInvitations()

module.exports = EventsCtrl
