class EventItemCtrl
  @$inject: ['$ionicPopup', '$state', 'Auth', 'SavedEvent', 'ngToast']
  constructor: (@$ionicPopup, @$state, @Auth, @SavedEvent, @ngToast) ->

  saveEvent: ->
    if not @Auth.flags.hasSavedEvent
      @Auth.setFlag 'hasSavedEvent', true
      @showSavedEventPopup()
      return

    # For latency compensation
    @savedEvent.interestedFriends = []
    @savedEvent.totalNumInterested++

    newSavedEvent =
      userId: @Auth.user.id
      eventId: @savedEvent.eventId
    @SavedEvent.save newSavedEvent
      .$promise.then (newSavedEvent) =>
        @savedEvent.interestedFriends = newSavedEvent.interestedFriends
      , =>
        # Revert latency compensation
        delete @savedEvent.interestedFriends
        @savedEvent.totalNumInterested--

        @ngToast.create 'Oops.. an error occurred..'

  showSavedEventPopup: ->
    @$ionicPopup.show
      title: 'Interested?'
      subTitle: "Tapping <i class=\"calendar-star-default\"></i> indicates that you\'re interested in \"#{@savedEvent.event.title}\""
      buttons: [
        text: 'Cancel'
      ,
        text: '<b>Interested</b>'
        onTap: (e) =>
          @saveEvent()
      ]

  didUserSaveEvent: ->
    angular.isArray @savedEvent.interestedFriends

  viewComments: ->
    @$state.go 'comments',
      id: @savedEvent.event.id
      event: @savedEvent.event

  viewInterested: ->
    @$state.go 'interested',
      id: @savedEvent.event.id
      event: @savedEvent.event

module.exports = EventItemCtrl
