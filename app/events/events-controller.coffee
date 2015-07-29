class EventsCtrl
  constructor: (@$ionicModal, @$scope, @$state, @$timeout, @$window, @Auth,
                @dividerHeight, @eventHeight, @Invitation, @transitionDuration) ->
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
    templateUrl = 'app/common/place-autocomplete/place-autocomplete.html'
    @$ionicModal.fromTemplateUrl templateUrl,
        scope: @$scope
        animation: 'slide-in-up'
      .then (modal) =>
        @setPlaceModal = modal

    @invitations =
      1:
        id: 1
        response: 0
        createdAt: new Date()
        updatedAt: new Date()
        lastViewed: new Date(1437672889145)
        event:
          id: 1
          title: 'bars?!?!?'
          datetime: new Date()
          place:
            name: '169 Bar'
            lat: 40.7138251
            long: -73.9897481
          comment: 'Go Go dancers galore'
          updatedAt: new Date(1437672889146)
        fromUser:
          id: 1
          name: 'Michael Kolodny'
          imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
      2:
        id: 2
        response: 1
        createdAt: new Date()
        updatedAt: new Date()
        lastViewed: new Date(1437672889146)
        event:
          id: 1
          title: 'Beach Day'
          createdAt: new Date()
          updatedAt: new Date(1437672889145)
        fromUser:
          id: 1
          name: 'Andrew Linfoot'
          imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
    @items = [
      isDivider: true
      title: 'New'
    , angular.extend({}, @invitations[1],
      isDivider: false
      wasJoined: false
      wasUpdated: true
    ),
      isDivider: true
      title: 'Down'
    , angular.extend({}, @invitations[2],
      isDivider: false
      wasJoined: true
      wasUpdated: false
    )]
    @setPositions @items

    return # Mock data for now.

    @Auth.getInvitations().then (invitations) =>
      # TODO: Save the invitations on the controller.
      @buildItems invitations
    , =>
      @getInvitationsError = true

  newEvent: {}

  toggleHasDate: ->
    if not @newEvent.hasDate
      @newEvent.hasDate = true
      if not @newEvent.datetime?
        @newEvent.datetime = new Date()
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

  moveItems: (invitations) ->
    @moving = true

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
    @Invitation.update invitation
      .$promise.then (_invitation) =>
        @invitations[_invitation.id] = _invitation
        @toggleIsExpanded item
        @moveItems @invitations
      , =>
        #item.respondError = true # Mock a successful response for now.

        @invitations[invitation.id] = invitation
        @toggleIsExpanded item
        @moveItems @invitations

  itemWasDeclined: (item) ->
    if item.response is @Invitation.declined
      return true

module.exports = EventsCtrl
