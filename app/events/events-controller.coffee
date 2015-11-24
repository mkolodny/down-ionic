class EventsCtrl
  @$inject: ['$meteor', '$scope', 'Auth', 'SavedEvent', 'RecommendedEvent', 'ngToast']
  constructor: (@$meteor, @$scope, @Auth, @SavedEvent, @RecommendedEvent, @ngToast) ->
    @$scope.$on '$ionicView.loaded', =>
      @refresh()

  handleLoadedData: ->
    if @savedEventsLoaded and @recommendedEventsLoaded
      delete @isLoading

      @items = @buildItems()

  refresh: ->
    @isLoading = true

    delete @savedEventsLoaded
    delete @recommendedEventsLoaded

    @getSavedEvents()
    @getRecommendedEvents()

  buildItems: ->

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

  isUserSavedEvent: (savedEvent) ->
    angular.isArray savedEvent.interestedFriends


module.exports = EventsCtrl
