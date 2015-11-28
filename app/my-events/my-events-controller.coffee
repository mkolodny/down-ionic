class MyEventsCtrl
  @$inject: ['$scope', '$stateParams', 'Auth', 'ngToast']
  constructor: (@$scope, @$stateParams, @Auth, @ngToast) ->
    @items = []

  getSavedEvents: ->
    @Auth.getSavedEvents().$promise
      .then (savedEvents) =>
        @savedEvents = savedEvents
        @items = @buildItems()
      , =>
        @ngToast.create 'Oops.. an error occurred..'

  buildItems: ->
    items = []

    for savedEvent in @savedEvents
      items.push
        savedEvent: savedEvent

    items
    
module.exports = MyEventsCtrl
