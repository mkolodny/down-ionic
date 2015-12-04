class InviteButtonCtrl
  @$inject: ['$ionicPopup', '$meteor', '$mixpanel', '$state', 'Auth', 'Friendship', 'ngToast']
  constructor: (@$ionicPopup, @$meteor, @$mixpanel, @$state, @Auth, @Friendship, @ngToast) ->
    # Bound to controller via directive
    #  @user
    #  @event
    @Messages = @$meteor.getCollectionByName 'messages'

  hasSentInvite: ->
    chatId = @Friendship.getChatId @user.id
    selector =
      chatId: chatId
      type: 'invite_action'
      'creator.id': "#{@Auth.user.id}"
      'meta.event.id': @event.id
    angular.isDefined @Messages.findOne(selector)

  hasBeenInvited: ->
    chatId = @Friendship.getChatId @user.id
    selector =
      chatId: chatId
      type: 'invite_action'
      'meta.event.id': @event.id
      'creator.id':
        $ne: "#{@Auth.user.id}"
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
    @$meteor.call 'sendEventInvite', creator, "#{@user.id}", @event
      .then =>
        @trackInvite @user
      , =>
        @ngToast.create 'Oops, an error occurred.'
      .finally =>
        @isLoading = false

  trackInvite: ->
    @$mixpanel.track 'Send Invite',
      'is friend': @Auth.isFriend @user.id
      'from screen': @$state.current.name

  showSentInvitePopup: ->
    @$ionicPopup.show
      title: 'Send Message?'
      subTitle: "Tapping \"Down?\" sends #{@user.name} a message
        asking if they\'re down for \"#{@event.title}\""
      buttons: [
        text: 'Cancel'
      ,
        text: '<b>Send</b>'
        onTap: @inviteUser
      ]

module.exports = InviteButtonCtrl