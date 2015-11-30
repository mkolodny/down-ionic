class MyEventsCtrl
  @$inject: ['$scope', '$stateParams', 'Auth', 'ngToast']
  constructor: (@$scope, @$stateParams, @Auth, @ngToast) ->
    @items = []

    @$scope.$on '$ionicView.loaded', =>
      @getSavedEvents()

  getSavedEvents: ->
    @Auth.getSavedEvents().$promise
      .then (savedEvents) =>
        @savedEvents = savedEvents
        @items = @buildItems()
      , =>
        @ngToast.create 'Oops.. an error occurred..'
      .finally =>
        @$scope.$broadcast 'scroll.refreshComplete'

  buildItems: ->
    items = []

    for savedEvent in @savedEvents
      items.push
        savedEvent: savedEvent

    items

module.exports = MyEventsCtrl
