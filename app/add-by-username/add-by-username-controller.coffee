class AddByUsernameCtrl
  @$inject: ['$timeout', 'Auth', 'User']
  constructor: (@$timeout, @Auth, @User) ->
    @user = @Auth.user

  search: ->
    @isSearching = true
    @friend = null

    # Cancel pending query
    @$timeout.cancel @timer

    # Search for the user after 300ms.
    # Save the current username to make sure the username is still the same after
    # 300ms.
    username = @username
    @timer = @$timeout =>
      @User.query {username: @username}
        .$promise.then (friends) =>
          @isSearching = false
          if @username is username
            if friends.length is 1
              @friend = friends[0]
        , =>
          if @username is username
            @searchError = true
            @isSearching = false
    , 300

module.exports = AddByUsernameCtrl
