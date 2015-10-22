class EventCtrl
  @$inject: ['$cordovaSocialSharing', '$ionicActionSheet', '$ionicHistory',
             '$ionicLoading', '$ionicModal', '$ionicPopup',
             '$ionicScrollDelegate', '$meteor', '$mixpanel',
             '$rootScope', '$scope', '$state', '$stateParams', '$timeout',
             '$window', 'Auth', 'Event',  'Invitation', 'LinkInvitation',
             'ngToast', 'User', '$filter']
  constructor: (@$cordovaSocialSharing, @$ionicActionSheet, @$ionicHistory,
                @$ionicLoading, @$ionicModal,
                @$ionicPopup, @$ionicScrollDelegate, @$meteor, @$mixpanel,
                @$rootScope, @$scope, @$state, @$stateParams, @$timeout, @$window,
                @Auth, @Event, @Invitation, @LinkInvitation, @ngToast, @User,
                @$filter) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    # Set Meteor collections on controller
    @Messages = @$meteor.getCollectionByName 'messages'
    @Chats = @$meteor.getCollectionByName 'chats'

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
    @$scope.$on '$ionicView.beforeEnter', =>
      # Get the members invitations.
      @updateMembers()

      # Subscribe to the event's chat.
      @$scope.$meteorSubscribe 'chat', "#{@event.id}"

      # Bind reactive variables
      @messages = @$meteor.collection @getMessages, false
      @newestMessage = @getNewestMessage()
      @chat = @getChat()

      # Watch for changes in newest message
      @watchNewestMessage()

      # Watch for changes in chat members
      @$scope.$watch =>
        @chat.members
      , @handleChatMembersChange

    @$scope.$on '$ionicView.afterEnter', =>
      # Show the nav border to distinguish the navbar from invite messages.
      @$rootScope.hideNavBottomBorder = false

    @$scope.$on '$ionicView.leave', =>
      # Remove angular-meteor bindings
      @messages.stop()
      @chat.stop()

  watchNewestMessage: =>
    # Mark messages as read as they come in
    #   and scroll to bottom
    @$scope.$watch =>
      newestMessage = @messages[@messages.length-1]
      if angular.isDefined newestMessage
        newestMessage._id
    , @handleNewMessage

  handleNewMessage: (newMessageId) =>
    if newMessageId is undefined
      return

    @$meteor.call 'readMessage', newMessageId
    @scrollBottom()

  getMessages: =>
    @Messages.find
      chatId: "#{@event.id}"
    ,
      sort:
        createdAt: 1
      transform: @transformMessage

  transformMessage: (message) =>
    message.creator = new @User message.creator
    message

  getNewestMessage: =>
    selector =
      chatId: "#{@event.id}"
    options =
      sort:
        createdAt: -1
    @$meteor.object @Messages, selector, false, options

  getChat: =>
    selector =
      chatId: "#{@event.id}"
    @$meteor.object @Chats, selector, false

  handleChatMembersChange: (chatMembers) =>
    chatMembers = chatMembers or []
    members = @members or []

    chatMemberIds = (member.userId for member in chatMembers)
    currentMemberIds = (member.id for member in members)
    chatMemberIds.sort()
    currentMemberIds.sort()

    if not angular.equals(chatMemberIds, currentMemberIds)
      @updateMembers()

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
        title: 'Chatting'

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

  toggleIsHeaderExpanded: ->
    if @isHeaderExpanded
      @isHeaderExpanded = false
      @headerTimeout = @$timeout =>
        @$rootScope.hideNavBottomBorder = false
      , 160
    else
      if @headerTimeout
        @$timeout.cancel @headerTimeout
      @isHeaderExpanded = true
      @$rootScope.hideNavBottomBorder = true

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
        @$ionicHistory.clearCache()
      .then =>
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
    @$mixpanel.track 'Send Message',
      'chat type': 'event'
    @message = null

  showMoreOptions: ->
    notificationText = if @invitation.muted then 'Turn On Notifications' \
        else 'Mute Notifications'
    hideSheet = null
    hasSharingPlugin = angular.isDefined @$window.plugins.socialsharing
    shareText = if hasSharingPlugin then 'Share On...' else 'Copy Group Link'
    options =
      buttons: [
        text: 'Send To...'
      ,
        text: shareText
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
          @shareLinkInvitation()
          hideSheet()
        if index is 2
          @toggleNotifications()
          hideSheet()

    hideSheet = @$ionicActionSheet.show options

  shareLinkInvitation: ->
    @$ionicLoading.show()

    linkInvitation =
      eventId: @event.id
      fromUserId: @Auth.user.id
    @LinkInvitation.save linkInvitation
      .$promise.then (linkInvitation) =>
        @$mixpanel.track 'Get Link Invitation'
        groupLink = "https://rallytap.com/e/#{linkInvitation.linkId}"
        # Show a "Copy Group Link" popup when the social sharing plugin isn\'t
        #   installed for backwards compatibility.
        if angular.isDefined @$window.plugins.socialsharing
          eventMessage = @getEventMessage()
          @$cordovaSocialSharing.share eventMessage, eventMessage, null, groupLink
        else
          @$ionicPopup.alert
            title: 'Copy Group Link'
            template: """
              <input id="share-link" value="#{groupLink}">
              """
            buttons: [
              text: 'Done'
              type: 'button-positive'
            ]
        @$ionicLoading.hide()
      , =>
        @ngToast.create 'For some reason, that didn\'t work.'
        @$ionicLoading.hide()

  getEventMessage: ->
    if angular.isDefined @event.datetime
      date = @$filter('date') @event.datetime, "EEE, MMM d 'at' h:mm a"
      dateString = " — #{date}"
    else
      dateString = ''

    if angular.isDefined @event.place
      placeString = " at #{@event.place.name}"
    else
      placeString = ''

    "#{@event.title}#{placeString}#{dateString}"

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

  scrollBottom: ->
    @$ionicScrollDelegate.$getByHandle 'event'
      .scrollBottom true

module.exports = EventCtrl
