class EventCtrl
  @$inject: ['$ionicActionSheet', '$ionicLoading', '$ionicModal', '$ionicPopup',
             '$ionicScrollDelegate', '$mixpanel', '$scope', '$state', '$stateParams', 'Asteroid',
             'Auth', 'Event',  'Invitation', 'LinkInvitation', 'ngToast', 'User']
  constructor: (@$ionicActionSheet, @$ionicLoading, @$ionicModal, @$ionicPopup,
                @$ionicScrollDelegate, @$mixpanel, @$scope, @$state, @$stateParams, @Asteroid,
                @Auth, @Event, @Invitation, @LinkInvitation, @ngToast, @User) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    # Give the event a long title variable name as a workaround for:
    #   https://github.com/driftyco/ionic/issues/2881
    @event.titleWithLongVariableName = @event.title

    # Init the set place modal.
    @$ionicModal.fromTemplateUrl 'app/guest-list/guest-list.html',
        scope: @$scope
        animation: 'slide-in-up'
    .then (modal) =>
      @guestListModal = modal

    # Clean up the guest list modal after hiding it.
    @$scope.$on '$destroy', =>
      @guestListModal.remove()

    # Set functions to control the guest list on the scope so that they can be
    # called from inside the modal.
    @$scope.guestList =
      hide: =>
        @guestListModal.hide()
      currentUser: @Auth.user

    # Start out at the most recent message.
    @$scope.$on '$ionicView.enter', =>
      # Subscribe to this event.
      @Asteroid.subscribe 'event', @event.id

      # Show the messages posted so far.
      @Messages = @Asteroid.getCollection 'messages'
      @messagesRQ = @Messages.reactiveQuery {eventId: "#{@event.id}"}
      @prepareMessages()
      @$ionicScrollDelegate.scrollBottom true

      # Watch for new messages.
      @messagesRQ.on 'change', @updateMessages

      # Watch for new members
      @Events = @Asteroid.getCollection 'events'
      @eventsRQ = @Events.reactiveQuery {_id: "#{@event.id}"}
      @eventsRQ.on 'change', @updateMembers

      # Show the members on the view.
      @updateMembers()

    # Stop listening for new messages and members.
    @$scope.$on '$ionicView.leave', =>
      @messagesRQ.off 'change', @updateMessages
      @eventsRQ.off 'change', @updateMembers

  updateMessages: =>
    @prepareMessages()
    if not @$scope.$$phase
      @$scope.$digest()
    if @maxTop is @$ionicScrollDelegate.getScrollPosition().top
      @$ionicScrollDelegate.scrollBottom true

  prepareMessages: ->
    @messages = angular.copy @messagesRQ.result
    for message in @messages
      message.creator = new @User message.creator

    # Sort the messages from oldest to newest.
    @messages.sort (a, b) ->
      if a.createdAt.$date < b.createdAt.$date
        return -1
      else
        return 1

    # Mark newest message as read
    if @messages.length > 0
      newestMessage = @messages[@messages.length - 1]
      @Asteroid.call 'readMessage', newestMessage._id

  updateMembers: =>
    @Invitation.getMemberInvitations {id: @event.id}
      .$promise.then (invitations) =>
        @members = (invitation.toUser for invitation in invitations)
        @buildGuestList invitations
        if not @$scope.$$phase
          @$scope.$digest()
      , =>
        @membersError = true

  buildGuestList: (memberInvitations) ->
    acceptedInvitations = (invitation for invitation in memberInvitations \
        when invitation.response is @Invitation.accepted)
    maybeInvitations = (invitation for invitation in memberInvitations \
        when invitation.response is @Invitation.maybe)

    items = []
    if acceptedInvitations.length > 0
      items.push
        isDivider: true
        title: 'Down'

      for invitation in acceptedInvitations
        items.push
          isDivider: false
          user: invitation.toUser

    if maybeInvitations.length > 0
      items.push
        isDivider: true
        title: 'Maybe'

      for invitation in maybeInvitations
        items.push
          isDivider: false
          user: invitation.toUser

    # Give each item an id so that we can use `track by` to improve rendering
    # performance.
    for item in items
      if item.isDivider
        item.id = item.title
      else
        item.id = item.user.id

    @$scope.guestList.items = items

  showGuestList: ->
    @guestListModal.show()

  saveMaxTop: ->
    # TODO: use angularjs-scroll-glue
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
      .$promise.then null, =>
        @ngToast.create 'For some reason, that didn\'t work.'

  maybeInvitation: ->
    @Invitation.updateResponse @invitation, @Invitation.maybe
      .$promise.then null, =>
        @ngToast.create 'For some reason, that didn\'t work.'

  declineInvitation: ->
    @$ionicLoading.show()

    @Invitation.updateResponse @invitation, @Invitation.declined
      .$promise.then =>
        @$state.go 'events'
      , =>
        @ngToast.create 'For some reason, that didn\'t work.'
      .finally =>
        @$ionicLoading.hide()

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
    @$mixpanel.track 'Send Message'
    @message = null

  showMoreOptions: ->
    notificationText = if @invitation.muted then 'Turn On Notifications' \
        else 'Mute Notifications'
    hideSheet = null
    options =
      buttons: [
        text: 'Send To...'
      ,
        text: 'Copy Group Link'
      ,
        text: notificationText
      ]
      cancelText: 'Cancel'
      buttonClicked: (index) =>
        if index is 0
          @$state.go 'inviteFriends',
            event: @event
          hideSheet()
        if index is 1
          @getLinkInvitation()
          hideSheet()
        if index is 2
          @toggleNotifications()
          hideSheet()

    hideSheet = @$ionicActionSheet.show options

  getLinkInvitation: ->
    @$ionicLoading.show()

    linkInvitation =
      eventId: @event.id
      fromUserId: @Auth.user.id
    @LinkInvitation.save linkInvitation
      .$promise.then (linkInvitation) =>
        @$mixpanel.track 'Get Link Invitation'
        @$ionicPopup.alert
          title: 'Copy Group Link'
          template: """
            <input id="share-link"
                   value="https://www.down.life/e/#{linkInvitation.linkId}">
            """
          buttons: [
            text: 'Done'
            type: 'button-positive'
          ]
        @$ionicLoading.hide()
      , =>
        @ngToast.create 'For some reason, that didn\'t work.'
        @$ionicLoading.hide()

  toggleNotifications: ->
    @$ionicLoading.show()

    @invitation.muted = not @invitation.muted
    @Invitation.update @invitation
      .$promise.then (invitation) =>
        message = if invitation.muted then 'Notifications are now off.' \
            else 'Notifications are now on.'
        @ngToast.create message
      , =>
        # Undo editing the invitation.
        @invitation.muted = not @invitation.muted
        @ngToast.create 'For some reason, that didn\'t work.'
      .finally =>
        @$ionicLoading.hide()

module.exports = EventCtrl
