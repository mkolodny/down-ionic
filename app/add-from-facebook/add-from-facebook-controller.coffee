class AddFromFacebookCtrl
  constructor: (@$scope, @Auth, @User) ->
    # Build the array of items to show in the view.
    if @Auth.user.facebookFriends?
      @showFacebookFriends @Auth.user.facebookFriends
    else
      @isLoading = true
      @refresh()

  showFacebookFriends: (facebookFriends) ->
    facebookFriends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1
    @items = []
    currentLetter = null
    for user in facebookFriends
      if user.name[0] != currentLetter
        @items.push
          isDivider: true
          title: user.name[0]
        currentLetter = user.name[0]

      @items.push
        isDivider: false
        user: user

  refresh: ->
    @User.getFacebookFriends()
      .$promise.then (facebookFriends) =>
        @showFacebookFriends facebookFriends
        @loadError = false
      , =>
        @loadError = true
      .finally =>
        @$scope.$broadcast 'scroll.refreshComplete'
        @isLoading = false

module.exports = AddFromFacebookCtrl
