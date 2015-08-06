class AddFromFacebook
  constructor: (@$scope, localStorageService, @User) ->
    @localStorage = localStorageService

    # Build the array of items to show in the view.
    # Mock them for now.
    @items = [
      isDivider: true
      title: 'A'
    ,
      isDivider: false
      user:
        id: 1
        name: 'Andrew Linfoot'
        username: 'a'
        imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
    ,
      isDivider: true
      title: 'M'
    ,
      isDivider: false
      user:
        id: 1
        name: 'Michael Kolodny'
        username: 'm'
        imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
    ]
    return

    facebookFriends = @localStorage.get 'facebookFriends'
    if facebookFriends is null
      @isLoading = true
      @refresh()
    else
      @showFacebookFriends facebookFriends

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
    @User.getFacebookFriends()
      .$promise.then (facebookFriends) =>
        @showFacebookFriends facebookFriends
        @$scope.$broadcast refreshCompleteEvent
        @loadError = false
        @isLoading = false
      , =>
        @$scope.$broadcast refreshCompleteEvent
        @loadError = true
        @isLoading = false

module.exports = AddFromFacebook
