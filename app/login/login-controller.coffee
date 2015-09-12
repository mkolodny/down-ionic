class LoginCtrl
  @$inject: ['$ionicLoading', '$scope', '$state', 'Auth']
  constructor: (@$ionicLoading, @$scope, @$state, @Auth) ->

  login: ->
    if not @validate()
      return

    @$ionicLoading.show
      template: '''
        <div class="loading-text">Sending you a verification text...</div>
        <ion-spinner icon="bubbles"></ion-spinner>
        '''

    @Auth.phone = @phone
    @Auth.sendVerificationText @phone
      .then =>
        @Auth.redirectForAuthState()
      , =>
        @error = 'For some reason, that didn\'t work'
      .finally =>
        @$ionicLoading.hide()

  validate: ->
    @$scope.loginForm.$valid

module.exports = LoginCtrl
