class EventsCtrl
  @$inject: ['$meteor', '$scope', 'Auth', 'SavedEvent', 'RecommendedEvent', 'ngToast']
  constructor: (@$meteor, @$scope, @Auth, @SavedEvent, @RecommendedEvent, @ngToast) ->
    @$scope.$on '$ionicView.loaded', =>
      @refresh()

  handleLoadedData: ->
    if @savedEventsLoaded and @recommendedEventsLoaded
      @items = @buildItems()
      @$scope.$broadcast 'scroll.refreshComplete'

  refresh: ->
    delete @savedEventsLoaded
    delete @recommendedEventsLoaded

    @getSavedEvents()
    @getRecommendedEvents()

  buildItems: ->
    items = []

    recommendedEventsMap = {}
    for savedEvent in @savedEvents
      items.push
        isDivider: false
        savedEvent: savedEvent

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
    @SavedEvent.query().$promise
      .then (savedEvents) =>
        @savedEvents = savedEvents
        @savedEventsLoaded = true
        @handleLoadedData()
      , =>
        @ngToast.create 'Oops.. an error occurred..'

  getRecommendedEvents: ->
    @RecommendedEvent.query().$promise
      .then (recommendedEvents) =>
        @recommendedEvents = recommendedEvents
        @recommendedEventsLoaded = true
        @handleLoadedData()
      , =>
        @ngToast.create 'Oops.. an error occurred..'

  saveEvent: (item) ->
    newSavedEvent =
      userId: @Auth.user.id
      eventId: item.savedEvent.eventId
    @SavedEvent.save(newSavedEvent).$promise
      .then (newSavedEvent) =>
        item.savedEvent.interestedFriends = newSavedEvent.interestedFriends
      , ->
        item.saveError = true

  didUserSaveEvent: (savedEvent) ->
    angular.isArray savedEvent.interestedFriends

module.exports = EventsCtrl
