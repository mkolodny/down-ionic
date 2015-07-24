class EventsCtrl
  constructor: (@Auth, @Invitation) ->
    return

    @Auth.getInvitations().then (invitations) =>
      # Build the list of items to show on the view.
      @items = []

      noResponseInvitations = (invitation for invitation in invitations \
          when invitation.response is @Invitation.noResponse)
      if noResponseInvitations.length > 0
        @items.push
          isDivider: true
          title: 'New'
        for invitation in noResponseInvitations
          @items.push angular.extend({isDivider: false}, invitation)

      sections =
        'Down': @Invitation.accepted
        'Maybe': @Invitation.maybe
      for title, response of sections
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
          for invitation in updatedInvitations
            @items.push angular.extend({isDivider: false}, invitation)
          for invitation in oldInvitations
            @items.push angular.extend({isDivider: false}, invitation)

      declinedInvitations = (invitation for invitation in invitations \
          when invitation.response is @Invitation.declined)
      if declinedInvitations.length > 0
        @items.push
          isDivider: true
          title: 'Can\'t'
        for invitation in declinedInvitations
          @items.push angular.extend({isDivider: false}, invitation)
    , =>
      @getInvitationsError = true

  items: [
    isDivider: true
    title: 'New'
  ,
    isDivider: false
    id: 1
    response: 0
    createdAt: new Date()
    updatedAt: new Date(1437672889146)
    lastViewed: new Date(1437672887387)
    event:
      id: 1
      title: 'bars?!?!?'
    fromUser:
      id: 1
      name: 'Michael Kolodny'
      imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
  ,
    isDivider: true
    title: 'Down'
  ,
    isDivider: false
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
