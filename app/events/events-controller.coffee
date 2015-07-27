class EventsCtrl
  constructor: (@$scope, @$state, @Auth, @Invitation) ->
    # Save the section titles.
    @sections = {}
    @sections[@Invitation.noResponse] =
      title: 'New'
      order: 1
    @sections[@Invitation.accepted] =
      title: 'Down'
      order: 2
    @sections[@Invitation.maybe] =
      title: 'Maybe'
      order: 3
    @sections[@Invitation.declined] =
      title: 'Can\'t'
      order: 4

    return # Mock data for now.

    @Auth.getInvitations().then (invitations) =>
      # Save the invitations on the controller.
      @buildItems invitations
    , =>
      @getInvitationsError = true

  buildItems: (invitations) ->
    # Build the list of items to show on the view.
    @items = []

    noResponseInvitations = (invitation for invitation in invitations \
        when invitation.response is @Invitation.noResponse)
    if noResponseInvitations.length > 0
      @items.push
        isDivider: true
        title: @sections[@Invitation.noResponse].title
        #id: -@sections[@Invitation.noResponse].order
      for invitation in noResponseInvitations
        @items.push angular.extend
          isDivider: false
          wasJoined: false
          wasUpdated: true
        , invitation

    accepted = {}
    accepted[@Invitation.accepted] = @sections[@Invitation.accepted].title
    maybe = {}
    maybe[@Invitation.maybe] = @sections[@Invitation.maybe].title
    for section in [accepted, maybe]
      for response, title of section
        response = parseInt response, 10
        updatedInvitations = (invitation for invitation in invitations \
            when invitation.response is response \
            and invitation.lastViewed < invitation.event.updatedAt)
        oldInvitations = (invitation for invitation in invitations \
            when invitation.response is response \
            and invitation.lastViewed >= invitation.event.updatedAt)
        if updatedInvitations.length > 0 or oldInvitations.length > 0
          @items.push
            isDivider: true
            title: title
            #id: -@sections[response].order
          for invitation in updatedInvitations
            @items.push angular.extend
              isDivider: false
              wasJoined: true
              wasUpdated: true
            , invitation
          for invitation in oldInvitations
            @items.push angular.extend
              isDivider: false
              wasJoined: true
              wasUpdated: false
            , invitation

    declinedInvitations = (invitation for invitation in invitations \
        when invitation.response is @Invitation.declined)
    if declinedInvitations.length > 0
      @items.push
        isDivider: true
        title: @sections[@Invitation.declined].title
        #id: -@sections[@Invitation.declined].order
      for invitation in declinedInvitations
        @items.push angular.extend
          isDivider: false
          wasJoined: false
          wasUpdated: false
        , invitation

  moveItem: (item, items) ->
    item.isExpanded = false
    item.wasUpdated = false
    if item.response in [@Invitation.accepted, @Invitation.maybe]
      item.wasJoined = true

    # Find the number of items in the no response section.
    noResponseItemsLength = 0
    for _item in items[1...items.length]
      if _item.isDivider
        break
      noResponseItemsLength += 1

    # Find `item`'s current index in `items`.
    index = -1
    for i in [1..noResponseItemsLength]
      if items[i] is item
        index = i

    # Get the index where each section starts.
    sectionStart = {}
    sectionStart[@Invitation.accepted] = -1
    sectionStart[@Invitation.maybe] = -1
    sectionStart[@Invitation.declined] = -1
    for i in [1...items.length]
      responses = [@Invitation.accepted, @Invitation.maybe, @Invitation.declined]
      for response in responses
        if items[i].isDivider \
            and items[i].title is @sections[response].title
          sectionStart[response] = i

    newIndex = null
    newSectionStart = sectionStart[item.response]
    if newSectionStart is -1
      # Find the index where the new section should go.
      if item.response is @Invitation.accepted
        newSectionStart = 1 + noResponseItemsLength
      else if item.response is @Invitation.maybe \
          and sectionStart[@Invitation.declined] isnt -1
        newSectionStart = sectionStart[@Invitation.declined]
      else
        # Insert the section at the end of the items.
        newSectionStart = items.length

      # This is the first item in the new section. Insert a new divider into the
      # `items`.
      newDivider =
        isDivider: true
        title: @sections[item.response].title
      items.splice newSectionStart, 0, newDivider
      newIndex = newSectionStart + 1
    else
      # Set the new index to the end of the new section.
      sectionItems = (_item for _item in items[sectionStart...items.length] \
          when _item.response is item.response)
      newIndex = newSectionStart + sectionItems.length + 1

    # Insert the item at the end of the section.
    items.splice newIndex, 0, item

    # Remove the item from its old position.
    items.splice index, 1

    if noResponseItemsLength is 1
      # Remove the no response divider.
      items.shift()

  toggleIsExpanded: (item) ->
    item.isExpanded = not item.isExpanded

  acceptInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.accepted

  maybeInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.maybe

  declineInvitation: (item, $event) ->
    @respondToInvitation item, $event, @Invitation.declined

  respondToInvitation: (item, $event, response) ->
    invitation = angular.copy item

    # Prevent calling the ion-item element's ng-click.
    $event.stopPropagation()

    # Clear any previous errors.
    item.respondError = null

    invitation.response = response
    invitation.lastViewed = new Date()
    @Invitation.update invitation
      .$promise.then (invitation) =>
        item.response = invitation.response

        @moveItem item, @items
      , =>
        #item.respondError = true # Mock a successful response for now.

        item.response = invitation.response

        @moveItem item, @items

  items: [
    isDivider: true
    title: 'New'
  ,
    isDivider: false
    wasJoined: false
    wasUpdated: true
    id: 1
    response: 0
    createdAt: new Date()
    updatedAt: new Date(1437672889146)
    lastViewed: null
    event:
      id: 1
      title: 'bars?!?!?'
      datetime: new Date()
      place:
        name: '169 Bar'
        lat: 40.7138251
        long: -73.9897481
      comment: 'Go Go dancers galore'
    fromUser:
      id: 1
      name: 'Michael Kolodny'
      imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
  ,
    isDivider: true
    title: 'Down'
  ,
    isDivider: false
    wasJoined: true
    wasUpdated: false
    id: 2
    response: 1
    createdAt: new Date()
    updatedAt: new Date(1437672887387)
    lastViewed: new Date(1437672889146)
    event:
      id: 1
      title: 'Beach Day'
    fromUser:
      id: 1
      name: 'Andrew Linfoot'
      imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
  ]

module.exports = EventsCtrl
