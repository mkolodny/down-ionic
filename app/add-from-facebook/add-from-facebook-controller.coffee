class AddFromFacebookCtrl
  constructor: (@$scope, localStorageService, @User) ->
    @localStorage = localStorageService

    # Build the array of items to show in the view.
    facebookFriends = @localStorage.get 'facebookFriends'
    if facebookFriends isnt null
      @showFacebookFriends facebookFriends
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
    refreshCompleteEvent = 'scroll.refreshComplete'
    @User.getFacebookFriends().$promise.then (facebookFriends) =>
      @showFacebookFriends facebookFriends
      @$scope.$broadcast refreshCompleteEvent
      @loadError = false
    , =>
      @$scope.$broadcast refreshCompleteEvent
      @loadError = true
    .finally =>
      @isLoading = false

module.exports = AddFromFacebookCtrl
