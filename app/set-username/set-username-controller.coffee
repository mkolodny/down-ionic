class SetUsernameCtrl
  @$inject: ['$ionicLoading', '$scope', '$state', 'Auth', 'User']
  constructor: (@$ionicLoading, @$scope, @$state, @Auth, @User) ->

  setUsername: ->
    if not @validate()
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
        @error = 'For some reason, that didn\'t work.'
      .finally =>
        @$ionicLoading.hide()

  validate: ->
    # TODO: Make sure the username is available before submitting.
    @$scope.setUsernameForm.$valid

module.exports = SetUsernameCtrl
