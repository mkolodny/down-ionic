class EventCtrl
  constructor: (@$ionicActionSheet, @$ionicLoading, @$ionicScrollDelegate, @$scope,
                @$state, @$stateParams, @Asteroid, @Auth, @Event, @Invitation,
                @User) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    # Give the event a long title variable name as a workaround for:
    #   https://github.com/driftyco/ionic/issues/2881
    @event.titleWithLongVariableName = @event.title

    # Start out at the most recent message.
    @$scope.$on '$ionicView.enter', =>
      @$ionicScrollDelegate.scrollBottom true

      # Get/subscribe to the messages posted in this event.
      @Asteroid.subscribe 'messages', @event.id
      @Messages = @Asteroid.getCollection 'messages'
      @messagesRQ = @Messages.reactiveQuery {eventId: "#{@event.id}"}
      @prepareMessages()

      # Watch for new messages.
      # TODO: Put this in a $ionicView.enter so that we re-start listening for new
      #   messages when we leave and come back.
      @messagesRQ.on 'change', =>
        @prepareMessages()
        if not @$scope.$$phase
          @$scope.$digest()
        if @maxTop is @$ionicScrollDelegate.getScrollPosition().top
          @$ionicScrollDelegate.scrollBottom true

    # TODO: Stop listening for new messages. Then start again event if the view was
    #   cached.
    @$scope.$on '$ionicView.leave', =>
      delete @messagesRQ

    @Invitation.getMemberInvitations {id: @event.id}
      .$promise.then (invitations) =>
        @members = (invitation.toUser for invitation in invitations)
      , =>
        @membersError = true

  prepareMessages: ->
    @messages = angular.copy @messagesRQ.result
    for message in @messages
      message.creator = new @User(message.creator)

    # Sort the messages from oldest to newest.
    @messages.sort (a, b) ->
      if a.createdAt.$date < b.createdAt.$date
        return -1
      else
        return 1

    # Mark newest message as read
    newestMessage = @messages[@messages.length - 1]
    @Asteroid.call 'readMessage', newestMessage._id

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
    message.creator.id is "#{@Auth.user.id}" # Meteor likes strings

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
      ,
        text: 'Report'
      ]
      cancelText: 'Cancel'
      buttonClicked: (index) =>
        if index is 0
          @toggleNotifications()
          hideSheet()
        if index is 1
          @$state.go 'inviteFriends',
            event: @event
          hideSheet()
        if index is 2
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
