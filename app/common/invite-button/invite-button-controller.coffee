class InviteButtonCtrl
  @$inject: ['$ionicPopup', '$meteor', '$mixpanel', '$state', 'Auth',
             'Friendship', 'ngToast']
  constructor: (@$ionicPopup, @$meteor, @$mixpanel, @$state, @Auth,
                @Friendship, @ngToast) ->
    # Bound to controller via directive
    #  @user
    #  @event
    #  @recommendedEvent
    @Messages = @$meteor.getCollectionByName 'messages'

  hasSentInvite: ->
    chatId = @Friendship.getChatId @user.id
    if angular.isDefined @event
      selector =
        chatId: chatId
        type: 'invite_action'
        'creator.id': "#{@Auth.user.id}"
        'meta.event.id': @event.id
    else
      selector =
        $or: [
          chatId: chatId
          type: 'invite_action'
          'creator.id': "#{@Auth.user.id}"
          'meta.recommendedEvent.id': @recommendedEvent.id
        ,
          chatId: chatId
          type: 'invite_action'
          'creator.id': "#{@Auth.user.id}"
          'meta.event.recommendedEvent': @recommendedEvent.id
        ]

    angular.isDefined @Messages.findOne(selector)

  hasBeenInvited: ->
    chatId = @Friendship.getChatId @user.id
    if angular.isDefined @event
      selector =
        chatId: chatId
        type: 'invite_action'
        'meta.event.id': @event.id
        'creator.id':
          $ne: "#{@Auth.user.id}"
    else
      selector =
        $or: [
          chatId: chatId
          type: 'invite_action'
          'meta.recommendedEvent.id': @recommendedEvent.id
          'creator.id':
            $ne: "#{@Auth.user.id}"
        ,
          chatId: chatId
          type: 'invite_action'
          'meta.event.recommendedEvent': @recommendedEvent.id
          'creator.id':
            $ne: "#{@Auth.user.id}"
        ]

    angular.isDefined @Messages.findOne(selector)

  inviteUser: =>
    if not @Auth.flags.hasSentInvite
      @Auth.setFlag 'hasSentInvite', true
      @showSentInvitePopup()
      return

    @isLoading = true

    creator =
      id: "#{@Auth.user.id}"
      name: @Auth.user.name
      firstName: @Auth.user.firstName
      lastName: @Auth.user.lastName
      imageUrl: @Auth.user.imageUrl

    if angular.isDefined @event
      methodName = 'sendEventInvite'
      methodData = @event
    else
      methodName = 'sendRecommendedEventInvite'
      methodData = @recommendedEvent

    @$meteor.call methodName, creator, "#{@user.id}", methodData
      .then =>
        @trackInvite()
      , =>
        @ngToast.create 'Oops, an error occurred.'
      .finally =>
        @isLoading = false

  trackInvite: ->
    @$mixpanel.track 'Send Invite',
      'is friend': @Auth.isFriend @user.id
      'from screen': @$state.current.name
      'from recommended': angular.isDefined @recommendedEvent

  showSentInvitePopup: ->
    @$ionicPopup.show
      title: 'Send Message?'
      subTitle: "Tapping \"Down?\" sends #{@user.firstName} the message \"Are you down for \"#{@event.title}\"?\""
      buttons: [
        text: 'Cancel'
      ,
        text: '<b>Send</b>'
        onTap: (e) =>
          @inviteUser()
          return
      ]

module.exports = InviteButtonCtrl
