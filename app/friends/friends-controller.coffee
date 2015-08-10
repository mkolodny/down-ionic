class FriendsCtrl
  # TODO: Handle when the user's friends aren't saved yet. We have to update the
  #   friends' locations somehow.
  constructor: (@$state, @Auth) ->
    friends = angular.copy @Auth.user.friends

    # Mock friends for now.
    friend1 =
      id: 1
      name: 'Michael Kolodny'
      username: 'm'
      imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
    friend2 =
      id: 2
      name: 'Andrew Linfoot'
      username: 'a'
      imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
    @nearbyFriends = [friend1]
    alphabeticalItems = [
      isDivider: true
      title: 'A'
    ,
      isDivider: false
      friend: friend2
    ,
      isDivider: true
      title: 'M'
    ,
      isDivider: false
      friend: friend1
    ]

    ###
    # Build the list of alphabetically sorted nearby friends.
    @nearbyFriends = (friend for id, friend of friends when @Auth.isNearby(friend))
    @nearbyFriends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1

    # Build the list of alphabetically sorted items.
    friends = (friend for id, friend of friends)
    friends.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1
    alphabeticalItems = []
    currentLetter = null
    for friend in friends
      if friend.name[0] != currentLetter
        alphabeticalItems.push
          isDivider: true
          title: friend.name[0]
        currentLetter = friend.name[0]

      alphabeticalItems.push
        isDivider: false
        friend: friend
    ###

    # Build the list of items to show in the collection.
    @items = []
    @items.push
      isDivider: true
      title: 'Nearby Friends'
    for friend in @nearbyFriends
      @items.push
        isDivider: false
        friend: friend
    for item in alphabeticalItems
      @items.push item

  addFriends: ->
    @$state.go 'addFriends'

module.exports = FriendsCtrl
