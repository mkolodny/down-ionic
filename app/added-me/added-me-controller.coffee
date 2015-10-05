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

  delete: (user) ->
    @users = (_user for _user in @users when _user.id isnt user.id)
    @Friendship.ack {friend: user.id}

module.exports = AddedMeCtrl
