class EventCtrl
  constructor: (@$ionicScrollDelegate, @$scope, @$state, @$stateParams, @Asteroid,
                @Auth, @Event, @Invitation) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    # Get/subscribe to the messages posted in this event.
    @Asteroid.subscribe 'messages', @event.id
    @Messages = @Asteroid.getCollection 'messages'
    @messagesRQ = @Messages.reactiveQuery {eventId: @event.id}
    @messages = angular.copy @messagesRQ.result

    # Sort the messages from oldest to newest.
    @sortMessages()

    # Start out at the most recent message.
    @$scope.$on '$ionicView.enter', =>
      @$ionicScrollDelegate.scrollBottom true

    # Watch for new messages.
    @messagesRQ.on 'change', =>
      @messages = angular.copy @messagesRQ.result
      @sortMessages()
      if not @$scope.$$phase
        @$scope.$digest()
      if @maxTop is @$ionicScrollDelegate.getScrollPosition().top
        @$ionicScrollDelegate.scrollBottom true

    @Invitation.getEventInvitations {id: @event.id}
      .$promise.then (invitations) =>
        @members = (invitation.toUser for invitation in invitations)
      , =>
        @membersError = true

  sortMessages: ->
    # Sort the messages from oldest to newest.
    @messages.sort (a, b) ->
      if a.createdAt.$date < b.createdAt.$date
        return -1
      else
        return 1

  saveMaxTop: ->
    @maxTop = @$ionicScrollDelegate.getScrollPosition().top

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
    message.type is 'action'

  isMyMessage: (message) ->
    message.creator.id is @Auth.user.id

  sendMessage: ->
    @Event.sendMessage @event, @message
    @message = null

module.exports = EventCtrl
