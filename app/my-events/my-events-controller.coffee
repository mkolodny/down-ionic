class MyEventsCtrl
  @$inject: ['$scope', '$stateParams', '$meteor', 'Auth', 'ngToast', 'Points',
             'User', '$state']
  constructor: (@$scope, @$stateParams, @$meteor, @Auth, @ngToast, @Points,
                @User, @$state) ->
    @items = []
    @commentsCount = {}
    @currentUser = @Auth.user

    @$scope.$on '$ionicView.loaded', =>
      @isLoading = true
      @refresh()

  handleLoadedData: ->
    if @savedEventsLoaded and @commentsCountLoaded
      @items = @buildItems()
      @isLoading = false
      @$scope.$broadcast 'scroll.refreshComplete'

  refresh: ->
    delete @savedEventsLoaded
    delete @commentsCountLoaded

    @getSavedEvents()

  buildItems: ->
    items = []

    for savedEvent in @savedEvents
      items.push
        savedEvent: savedEvent
        commentsCount: @commentsCount[savedEvent.eventId]

    items

  getSavedEvents: ->
    @Auth.getSavedEvents()
      .$promise.then (savedEvents) =>
        @savedEvents = savedEvents
        @savedEventsLoaded = true
        @getCommentsCount()
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

  viewEvent: (savedEvent) ->
    @$state.go 'saved.event',
      savedEvent: savedEvent
      commentsCount: @commentsCount[savedEvent.eventId]


module.exports = MyEventsCtrl
