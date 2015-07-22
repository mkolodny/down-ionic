class AddFriendsSignupCtrl
  constructor: (@$state) ->

  done: ->
    @$state.go 'events'

module.exports = AddFriendsSignupCtrl
