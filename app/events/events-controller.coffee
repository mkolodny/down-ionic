class EventsCtrl
  @$inject: ['$meteor', '$scope', '$state', 'Auth', 'SavedEvent',
             'RecommendedEvent', 'ngToast', 'User', 'Event', '$mixpanel']
  constructor: (@$meteor, @$scope, @$state, @Auth, @SavedEvent, @RecommendedEvent,
                @ngToast, @User, @Event, @$mixpanel) ->
    @items = []
    @commentsCount = {}
    @currentUser = @Auth.user

    @$scope.$on '$ionicView.loaded', =>
      @isLoading = true
      @refresh()

  handleLoadedData: ->
    if @savedEventsLoaded and @recommendedEventsLoaded \
        and @commentsCountLoaded
      @items = @buildItems()
      @isLoading = false
      @$scope.$broadcast 'scroll.refreshComplete'

  refresh: ->
    delete @savedEventsLoaded
    delete @recommendedEventsLoaded
    delete @commentsCountLoaded

    @getSavedEvents()
    @getRecommendedEvents()

  buildItems: ->
    items = []

    recommendedEventsMap = {}
    for savedEvent in @savedEvents
      items.push
        isDivider: false
        savedEvent: savedEvent
        commentsCount: @commentsCount[savedEvent.eventId]

      recommendedEvent = savedEvent.event?.recommendedEvent
      if angular.isDefined recommendedEvent
        recommendedEventsMap[recommendedEvent] = true

    recommendedEventItems = []
    for recommendedEvent in @recommendedEvents
      if recommendedEventsMap[recommendedEvent.id] is undefined
        recommendedEventItems.push
          isDivider: false
          recommendedEvent: recommendedEvent

    if recommendedEventItems.length > 0
      items.push
        isDivider: true
        title: 'Recommended'
      items = items.concat recommendedEventItems

    items

  getSavedEvents: ->
    @SavedEvent.query()
      .$promise.then (savedEvents) =>
        @savedEvents = savedEvents
        @savedEventsLoaded = true
        @getCommentsCount()
        @handleLoadedData()
      , =>
        @ngToast.create 'Oops.. an error occurred..'

  getRecommendedEvents: ->
    @RecommendedEvent.query()
      .$promise.then (recommendedEvents) =>
        @recommendedEvents = recommendedEvents
        @recommendedEventsLoaded = true
        @handleLoadedData()
      , =>
        @ngToast.create 'Oops.. an error occurred..'

  getCommentsCount: ->
    eventIds = (savedEvent.eventId for savedEvent in @savedEvents)
    @$meteor.call 'getCommentsCount', eventIds
      .then (commentsCount) =>
        for countObj in commentsCount
          @commentsCount[countObj._id] = countObj.count
        @commentsCountLoaded = true
        @handleLoadedData()
      , =>
        @ngToast.create 'Oops.. an error occurred..'

  createEvent: ->
    @$state.go 'createEvent'

  saveRecommendedEvent: (recommendedEvent) ->
    event = angular.copy recommendedEvent
    event.recommendedEvent = recommendedEvent.id
    delete event.id
    recommendedEvent.wasSaved = true
    @Event.save(event).$promise.then =>
      @$mixpanel.track 'Create Event',
        'from recommended': true
        place: angular.isDefined recommendedEvent.place
        time: angular.isDefined recommendedEvent.datetime
    , =>
      delete recommendedEvent.wasSaved
      @ngToast.create 'Oops.. an error occurred..'

module.exports = EventsCtrl
