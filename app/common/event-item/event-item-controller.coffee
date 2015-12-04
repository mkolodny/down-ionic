class EventItemCtrl
  @$inject: ['$filter', '$mixpanel', '$ionicPopup', '$state', 'Auth',
             'SavedEvent', 'ngToast']
  constructor: (@$filter, @$mixpanel, @$ionicPopup, @$state, @Auth,
                @SavedEvent, @ngToast) ->

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
        @$mixpanel.track 'Save Event',
          'total num interested': @savedEvent.totalNumInterested - 1
          'time since posted': @$filter('timeAgo')(@savedEvent.createdAt.getTime())
          time: angular.isDefined @savedEvent.event.datetime
          place: angular.isDefined @savedEvent.event.place
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
          return
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
