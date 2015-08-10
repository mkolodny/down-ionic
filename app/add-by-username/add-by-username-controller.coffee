class AddByUsernameCtrl
  constructor: (@$timeout, @Auth, @User) ->
    @user = @Auth.user

  search: ->
    @isSearching = true

    # Search for the user after 300ms.
    # Save the current username to make sure the username is still the same after
    # 300ms.
    username = @username
    @$timeout =>
      @User.query {username: @username}
        .$promise.then (friends) =>
          if @username is username
            if friends.length is 1
              @friend = friends[0]
            @isSearching = false
        , =>
          if @username is username
            @searchError = true
            @isSearching = false
    , 300

module.exports = AddByUsernameCtrl
