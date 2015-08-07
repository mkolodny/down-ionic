class Event
  constructor: (@$state, @$stateParams, @Asteroid, @Auth, @Invitation) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    # Mock the messages for now.
    oldest = new Date()
    middle = new Date(oldest.getTime()+1)
    newest = new Date(middle.getTime()+1)
    @messages = [
      _id: 1
      creator:
        id: 1
        name: 'Michael Kolodny'
        imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
      createdAt: oldest
      text: 'I\'m in love with a robot.'
      eventId: @event.id
      type: 'text'
    ,
      _id: 2
      creator: null
      createdAt: middle
      text: 'Michael Jordan is down'
      eventId: @event.id
      type: 'action'
    ,
      _id: 3
      creator:
        id: 1
        name: 'Andrew Linfoot'
        imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
      createdAt: newest
      text: 'That place is super sticky. I love it.'
      eventId: @event.id
      type: 'text'
    ]
    ###
    # Get/subscribe to the messages posted in this event.
    @Asteroid.subscribe 'messages', @event.id
    Messages = @Asteroid.getCollection 'messages'
    messagesRQ = Messages.reactiveQuery {eventId: @event.id}
    @messages = messagesRQ.result

    # Sort the messages from oldest to newest.
    @sortMessages()

    # Watch for new messages.
    messagesRQ.on 'change', =>
      @sortMessages()
    ###

    @Invitation.getEventInvitations {id: @event.id}
      .$promise.then (invitations) =>
        @members = (invitation.toUser for invitation in invitations)
      , =>
        # Mock the members for now.
        @members = [
          id: 1
          name: 'Michael Kolodny'
          imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
        ,
          id: 1
          name: 'Andrew Linfoot'
          imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
        ]
        return
        @membersError = true

  sortMessages: ->
    # Sort the messages from oldest to newest.
    @messages.sort (a, b) ->
      if a.createdAt < b.createdAt
        return -1
      else
        return 1

  toggleIsHeaderExpanded: ->
    if @isHeaderExpanded
      @isHeaderExpanded = false
    else
      @isHeaderExpanded = true

  isAccepted: ->
    @invitation.response is @Invitation.accepted

  isMaybe: ->
    @invitation.response is @Invitation.maybe

  acceptInvitation: ->
    response = @invitation.response
    @invitation.response = @Invitation.accepted
    @Invitation.update @invitation
      .$promise.then =>
        null
      , =>
        @invitation.response = response

  maybeInvitation: ->
    response = @invitation.response
    @invitation.response = @Invitation.maybe
    @Invitation.update @invitation
      .$promise.then =>
        null
      , =>
        @invitation.response = response

  declineInvitation: ->
    response = @invitation.response
    @invitation.response = @Invitation.declined
    @Invitation.update @invitation
      .$promise.then =>
        null
      , =>
        @invitation.response = response

    @$state.go 'events'

  isActionMessage: (message) ->
    if message.type is 'action'
      return true
    else
      return false

  isMyMessage: (message) ->
    message.creator.id is @Auth.user.id

module.exports = Event
