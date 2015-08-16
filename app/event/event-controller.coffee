class EventCtrl
  constructor: (@$scope, @$state, @$stateParams, @Asteroid, @Auth, @Event, @Invitation) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    # Get/subscribe to the messages posted in this event.
    @Asteroid.subscribe 'messages', @event.id
    @Messages = @Asteroid.getCollection 'messages'
    @messagesRQ = @Messages.reactiveQuery {eventId: @event.id}
    @messages = angular.copy @messagesRQ.result

    # Sort the messages from oldest to newest.
    @sortMessages()

    # Watch for new messages.
    @messagesRQ.on 'change', =>
      @messages = angular.copy @messagesRQ.result
      @sortMessages()
      if not @$scope.$$phase
        @$scope.$digest()

    @Invitation.getEventInvitations {id: @event.id}
      .$promise.then (invitations) =>
        @members = (invitation.toUser for invitation in invitations)
      , =>
        @membersError = true

  sortMessages: ->
    # Sort the messages from oldest to newest.
    @messages.sort (a, b) ->
      if a.createdAt < b.createdAt
        return 1
      else
        return -1

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

  sendMessage: ->
    @Event.sendMessage @event, @message

module.exports = EventCtrl
