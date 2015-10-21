class SetUsernameCtrl
  @$inject: ['$ionicLoading', '$scope', '$state', 'Auth', 'User']
  constructor: (@$ionicLoading, @$scope, @$state, @Auth, @User) ->

  setUsername: ->
    # Clear any previous error.
    @error = null

    if not @validate()
      return

    # Don't let users take the username "rallytap".
    if @username is 'rallytap'
      @error = 'Unfortunately, that username is taken.'
      return

    @$ionicLoading.show
      template: '''
        <div class="loading-text">Saving...</div>
        <ion-spinner icon="bubbles"></ion-spinner>
        '''

    user = angular.copy @Auth.user
    user.username = @username
    @User.update user
      .$promise.then (user) =>
        @Auth.setUser user
        @Auth.redirectForAuthState()
      , =>
        @error = 'Unfortunately, that username is taken.'
      .finally =>
        @$ionicLoading.hide()

  validate: ->
    # TODO: Make sure the username is available before submitting.
    @$scope.setUsernameForm.$valid

module.exports = SetUsernameCtrl
