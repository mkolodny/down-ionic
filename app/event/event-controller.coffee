class Event
  @$inject: ['$stateParams', '$rootScope', '$scope']
  constructor: (@$stateParams, @$rootScope, @$scope) ->
    @savedEvent = @$stateParams.savedEvent
    @commentsCount = @$stateParams.commentsCount
    @$scope.$on '$ionicView.beforeEnter', =>
      @$rootScope.hideTabBar = true



module.exports = Event
