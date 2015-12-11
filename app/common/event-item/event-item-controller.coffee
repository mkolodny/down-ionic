class EventItemCtrl
  @$inject: ['$filter', '$ionicPopup', '$ionicScrollDelegate', '$mixpanel',
             '$state', 'Auth', 'SavedEvent', 'ngToast', 'Event']
  constructor: (@$filter, @$ionicPopup, @$ionicScrollDelegate, @$mixpanel,
                @$state, @Auth, @SavedEvent, @ngToast, @Event) ->
    # Bound to controller via directive
    #  @savedEvent
    #  @recommendedEvent
    #  @commentsCount
  getEvent: ->
    if angular.isDefined @savedEvent
      @savedEvent.event
    else
      @recommendedEvent

  save: ->
    if not @Auth.flags.hasSavedEvent
      @Auth.setFlag 'hasSavedEvent', true
      @showSavedEventPopup()
      return

    if angular.isDefined @savedEvent
      @saveEvent()
    else
      @saveRecommendedEvent()

  saveEvent: ->
    # For latency compensation
    @savedEvent.interestedFriends = []
    @savedEvent.totalNumInterested++
    @$ionicScrollDelegate.resize()
    @savedEvent.isLoadingInterested = true

    newSavedEvent =
      userId: @Auth.user.id
      eventId: @savedEvent.eventId
    @SavedEvent.save newSavedEvent
      .$promise.then (newSavedEvent) =>
        @savedEvent.interestedFriends = newSavedEvent.interestedFriends
        @$ionicScrollDelegate.resize()
        @$mixpanel.track 'Save Event',
          'total num interested': @savedEvent.totalNumInterested - 1
          'time since posted': @$filter('timeAgo') @savedEvent.createdAt.getTime()
          'has time': angular.isDefined @savedEvent.event.datetime
          'has place': angular.isDefined @savedEvent.event.place
      , =>
        # Revert latency compensation
        delete @savedEvent.interestedFriends
        @savedEvent.totalNumInterested--

        @ngToast.create 'Oops.. an error occurred..'
      .finally =>
        @savedEvent.isLoadingInterested = false

  saveRecommendedEvent: ->
    event = angular.copy @recommendedEvent
    event.recommendedEvent = @recommendedEvent.id
    delete event.id
    @recommendedEvent.wasSaved = true
    @Event.save(event).$promise.then =>
      @$mixpanel.track 'Create Event',
        'from recommended': true
        'has place': angular.isDefined @recommendedEvent.place
        'has time': angular.isDefined @recommendedEvent.datetime
    , =>
      delete @recommendedEvent.wasSaved
      @ngToast.create 'Oops.. an error occurred..'

  showSavedEventPopup: ->
    @$ionicPopup.show
      title: 'Interested?'
      subTitle: "
        Tapping <i class=\"calendar-star-default\"></i> indicates that
        you\'re interested in \"#{@getEvent().title}\"
      "
      buttons: [
        text: 'Cancel'
      ,
        text: '<b>Interested</b>'
        onTap: (e) =>
          @save()
          return
      ]

  didUserSaveEvent: ->
    if angular.isDefined @savedEvent
      angular.isArray @savedEvent.interestedFriends
    else
      angular.isDefined @recommendedEvent.wasSaved

  viewComments: ->
    stateName = "#{@$state.current.parent}.comments"
    @$state.go stateName,
      id: @savedEvent.event.id
      event: @savedEvent.event

  viewInterested: ->
    stateName = "#{@$state.current.parent}.interested"
    @$state.go stateName,
      id: @savedEvent.event.id
      event: @savedEvent.event

module.exports = EventItemCtrl
