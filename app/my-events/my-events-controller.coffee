class MyEventsCtrl
  @$inject: ['$scope', '$stateParams', 'Auth', 'ngToast']
  constructor: (@$scope, @$stateParams, @Auth, @ngToast) ->
    @items = []

    @$scope.$on '$ionicView.loaded', =>
      @getSavedEvents()

  getSavedEvents: ->
    @isLoading = true

    @Auth.getSavedEvents().$promise
      .then (savedEvents) =>
        @savedEvents = savedEvents
        @items = @buildItems()
      , =>
        @ngToast.create 'Oops.. an error occurred..'
      .finally =>
        @isLoading = false

  buildItems: ->
    items = []

    for savedEvent in @savedEvents
      items.push
        savedEvent: savedEvent

    items

module.exports = MyEventsCtrl
