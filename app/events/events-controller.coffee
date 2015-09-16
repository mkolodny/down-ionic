class EventsCtrl
  @$inject: ['$cordovaDatePicker', '$ionicHistory', '$ionicLoading', '$ionicModal',
             '$scope', '$state', '$timeout', 'Asteroid', 'Invitation', 'ngToast',
             'Auth']
  constructor: (@$cordovaDatePicker, @$ionicHistory, @$ionicLoading, @$ionicModal,
                @$scope, @$state, @$timeout, @Asteroid, @Invitation, @ngToast,
                @Auth) ->
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
        lat: place.geometry.location.lat()
        long: place.geometry.location.lng()
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
      if angular.isDate @newEvent.datetime
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

    # Save the section titles.
    sections = {}
    sections[@Invitation.noResponse] = {title: 'New'}
    sections[@Invitation.accepted] = {title: 'Down'}
    sections[@Invitation.maybe] = {title: 'Maybe'}
    sections[@Invitation.declined] = {title: 'Can\'t'}

    noResponseInvitations = (invitation for id, invitation of invitations \
        when invitation.response is @Invitation.noResponse)
    noResponseInvitations.sort (a, b) ->
      aCreatedAt = a.event.latestMessage?.createdAt or a.event.createdAt
      bCreatedAt = b.event.latestMessage?.createdAt or b.event.createdAt
      if aCreatedAt > bCreatedAt
        return -1
      else
        return 1
    if noResponseInvitations.length > 0
      items.push
        isDivider: true
        title: sections[@Invitation.noResponse].title
        id: sections[@Invitation.noResponse].title
      for invitation in noResponseInvitations
        items.push angular.extend
          isDivider: false
          wasJoined: false
          invitation: invitation
          id: invitation.id

    for response in [@Invitation.accepted, @Invitation.maybe]
      title = sections[response].title
      sectionInvitations = (invitation for id, invitation of invitations \
          when invitation.response is response)

      # Sort by latestMessage time.
      sectionInvitations.sort (a, b) ->
        aCreatedAt = a.event.latestMessage?.createdAt or a.event.createdAt
        bCreatedAt = b.event.latestMessage?.createdAt or b.event.createdAt
        if aCreatedAt > bCreatedAt
          return -1
        else
          return 1

      if sectionInvitations.length > 0
        items.push
          isDivider: true
          title: title
          id: title
        for invitation in sectionInvitations
          items.push angular.extend
            isDivider: false
            wasJoined: true
            invitation: invitation
            id: invitation.id

    declinedInvitations = (invitation for id, invitation of invitations \
        when invitation.response is @Invitation.declined)
    declinedInvitations.sort (a, b) ->
      aCreatedAt = a.event.latestMessage?.createdAt or a.event.createdAt
      bCreatedAt = b.event.latestMessage?.createdAt or b.event.createdAt
      if aCreatedAt > bCreatedAt
        return -1
      else
        return 1
    if declinedInvitations.length > 0
      items.push
        isDivider: true
        title: sections[@Invitation.declined].title
        id: sections[@Invitation.declined].title
      for invitation in declinedInvitations
        items.push angular.extend
          isDivider: false
          wasJoined: false
          invitation: invitation
          id: invitation.id
    items

  eventsMessagesSubscribe: (events) ->
    # Subscribe to the messages posted in each event.
    for event in events
      @Asteroid.subscribe 'event', event.id

    Messages = @Asteroid.getCollection 'messages'
    Events = @Asteroid.getCollection 'events'
    for event in events
      messagesRQ = Messages.reactiveQuery {eventId: "#{event.id}" }
      eventsRQ = Events.reactiveQuery {_id: "#{event.id}" }

      # Keep the same value of `messagesRQ` even after the variable changes
      #   next time through the loop.
      do (event, messagesRQ, eventsRQ) =>
        # Set the latest message on the event.
        messages = angular.copy messagesRQ.result
        @setLatestMessage event, messages

        # Whenever a new message gets posted on the event, set the
        # latest message on the event.
        messagesRQ.on 'change', (_id) =>
          messages = angular.copy messagesRQ.result
          if @isNewMessage event, _id
            @setLatestMessage event, messages

        # Whenever an event changes, check is the lastest message has been read
        eventsRQ.on 'change', =>
          latestMessage = messages[0]
          if event.latestMessage isnt undefined and latestMessage isnt undefined
            event.latestMessage.wasRead = @getWasRead latestMessage

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
    if message isnt undefined
      message.createdAt.$date > event.latestMessage?.createdAt?.getTime()

  setLatestMessage: (event, messages) ->
    if messages.length is 0 then return

    # Sort the messages from newest to oldest.
    messages.sort (a, b) ->
      if a.createdAt.$date > b.createdAt.$date
        return -1
      else
        return 1

    latestMessage = messages[0]

    # Only update the event if the latest message is newer than the updatedAt.
    if latestMessage.createdAt.$date <= event.latestMessage?.createdAt?.getTime()
      return

    # Update the latest message text
    event.latestMessage = {}
    if latestMessage.type is 'text'
      firstName = latestMessage.creator.firstName
      event.latestMessage.text = "#{firstName}: #{latestMessage.text}"
    else
      event.latestMessage.text = latestMessage.text

    # Set unread or not for message
    event.latestMessage.wasRead = @getWasRead latestMessage

    # Update the latest message createdAt date.
    event.latestMessage.createdAt = new Date latestMessage.createdAt.$date

    # Move the event's updated item.
    for item in @items
      if item.invitation?.event.id is event.id
        @items = @buildItems @invitations

  getWasRead: (message) ->
    Events = @Asteroid.getCollection 'events'
    eventsRQ = Events.reactiveQuery {_id: message.eventId}
    event = eventsRQ.result[0]

    # Have to check if event exists in case the
    # subscribe hasn't returned the event yet
    if event is undefined
      return true

    currentUser = (member for member in event.members \
        when member.userId is "#{@Auth.user.id}")[0]

    # Make sure the current user is still a member.
    if currentUser is undefined
      return true

    currentUser.lastRead.$date >= message.createdAt.$date

  toggleIsExpanded: (item) ->
    item.isExpanded = not item.isExpanded

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
