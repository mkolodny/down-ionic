class AddFromFacebookCtrl
  @$inject: ['$scope', 'Auth']
  constructor: (@$scope, @Auth) ->
    # Build the array of items to show in the view.
    if @Auth.user.facebookFriends?
      @showFacebookFriends @Auth.user.facebookFriends
    else
      @isLoading = true
      @refresh()

  showFacebookFriends: (facebookFriendsDict) ->
    facebookFriends = (friend for id, friend of facebookFriendsDict)
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
    @Auth.getFacebookFriends()
      .$promise.then (facebookFriends) =>
        @showFacebookFriends facebookFriends
        @loadError = false
      , =>
        @loadError = true
      .finally =>
        @$scope.$broadcast 'scroll.refreshComplete'
        @isLoading = false

module.exports = AddFromFacebookCtrl
