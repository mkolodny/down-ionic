class AddedMeCtrl
  @$inject: ['$scope', 'Auth', 'Friendship']
  constructor: (@$scope, @Auth, @Friendship) ->
    @$scope.$on '$ionicView.beforeEnter', =>
      @isLoading = true
      @refresh()

  refresh: ->
    # Reset any errors.
    @error = null

    @Auth.getAddedMe()
      .$promise.then (addedMe) =>
        @users = addedMe
      , =>
        @error = 'Sorry, we weren\'t able to reach the server.'
      .finally =>
        @$scope.$broadcast 'scroll.refreshComplete'
        @isLoading = false


module.exports = AddedMeCtrl
