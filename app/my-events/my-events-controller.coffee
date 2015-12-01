class MyEventsCtrl
  @$inject: ['$scope', '$stateParams', 'Auth', 'ngToast', 'User']
  constructor: (@$scope, @$stateParams, @Auth, @ngToast, @User) ->
    @items = []
    # Mock data
    @items = [
      isDivider: false
      savedEvent:
        event:
          title: 'Get jiggy with it'
        numInterestedFriends: 7
        interestedFriends: [new @User(
          name: 'Chris MacPherson'
          imageUrl: 'https://graph.facebook.com/v2.2/1012980509/picture')
        , new @User(
          name: 'Chris MacPherson'
          imageUrl: 'https://graph.facebook.com/v2.2/1012980509/picture')
        ]
    ,
      isDivider: false
      savedEvent:
        event:
          title: 'Pickup bball'
        numInterestedFriends: 7
    ]

    @$scope.$on '$ionicView.loaded', =>
      @getSavedEvents()

  getSavedEvents: ->
    @Auth.getSavedEvents()
      .$promise.then (savedEvents) =>
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
