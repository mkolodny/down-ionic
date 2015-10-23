class TeamCtrl
  @$inject: ['$meteor', '$state', 'Auth']
  constructor: (@$meteor, @$state, @Auth) ->

  login: ->
    # Clear any previous error.
    @error = null
    error = 'Son of a.... That didn\'t work.'

    @Auth.getTeamRallytap()
      .$promise.then (user) =>
        @$meteor.loginWithPassword "#{user.id}", user.authtoken
          .then =>
            @Auth.setUser user
            @$state.go 'events'
        , =>
          @error = error
      , =>
        @error = error

module.exports = TeamCtrl
