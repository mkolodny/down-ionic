class EventsCtrl
  constructor: (@Invitation) ->
    return
    @Invitation.getMyInvitations().then (events) ->
      # Create a list of the user's invitations, with the event set on the
      # invitation.
      invitations = []
      #for event in events

      items = []
      items.push
        isDivider: true
        title: 'New'

  items: [
    isDivider: true
    title: 'New'
  ,
    isDivider: false
    isNew: true
    id: 1
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
    isNew: false
    id: 2
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
