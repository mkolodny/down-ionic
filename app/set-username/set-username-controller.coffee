class SetUsernameCtrl
  constructor: (@$scope, @$state, @Auth, @User) ->

  setUsername: ->
    if not @validate()
      return

    user = angular.copy @Auth.user
    user.username = @username
    @User.update(user).$promise.then (user) =>
      @Auth.user = user
      @Auth.redirectForAuthState()
    , =>
      @error = 'For some reason, that didn\'t work.'

  validate: ->
    # TODO: Make sure the username is available before submitting.
    @$scope.setUsernameForm.$valid

module.exports = SetUsernameCtrl
