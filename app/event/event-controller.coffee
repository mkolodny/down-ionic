class EventCtrl
  constructor: (@$ionicActionSheet, @$ionicLoading, @$ionicScrollDelegate, @$scope,
                @$state, @$stateParams, @Asteroid, @Auth, @Event, @Invitation) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    # Give the event a long title variable name as a workaround for:
    #   https://github.com/driftyco/ionic/issues/2881
    @event.titleWithLongVariableName = @event.title

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
      # Update last viewed time
      @Invitation.update @invitation

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
    @Invitation.updateResponse @invitation, @Invitation.accepted

  maybeInvitation: ->
    @Invitation.updateResponse @invitation, @Invitation.maybe

  declineInvitation: ->
    @Invitation.updateResponse @invitation, @Invitation.declined

    @$state.go 'events'

  isActionMessage: (message) ->
    actions = [
      @Invitation.acceptAction
      @Invitation.maybeAction
      @Invitation.declineAction
    ]
    message.type in actions

  isMyMessage: (message) ->
    message.creator.id is @Auth.user.id

  sendMessage: ->
    @Event.sendMessage @event, @message
    @message = null

  showMoreOptions: ->
    notificationText = if @invitation.muted then 'Turn On Notifications' \
        else 'Mute Notifications'
    hideSheet = null
    options =
      buttons: [
        text: notificationText
      ,
        text: 'Send To..'
      ]
      cancelText: 'Cancel'
      buttonClicked: (index) =>
        if index is 0
          @toggleNotifications()
          hideSheet()
        if index is 1
          @$state.go 'inviteFriends', {event: @event}
          hideSheet()

    hideSheet = @$ionicActionSheet.show options

  toggleNotifications: ->
    @$ionicLoading.show()

    @invitation.muted = not @invitation.muted
    @Invitation.update @invitation
      .$promise.then null, =>
        # Undo editing the invitation.
        @invitation.muted = not @invitation.muted
      .finally =>
        @$ionicLoading.hide()

module.exports = EventCtrl
