class FindFriendsCtrl
  constructor: (@$state, @Auth, @User) ->
    # Use mock data for now.
    user =
      id: 2
      name: 'Andrew Linfoot'
      username: 'a'
      imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
    @Auth.friends[user.id] = new @User(user)
    return

    @User.getFacebookFriends().$promise.then (facebookFriends) =>
      # Set the user's facebook friends on the Auth service.
      # TODO: Figure out why this is setting the friends on the global Auth service
      # instead of the copy during testing.
      for friend in facebookFriends
        @Auth.friends[friend.id] = new @User(friend)

      # Build the list of items to show in the view.
      items = [
        isDivider: true
        title: 'Friends Using Down'
      ]
      for friend in facebookFriends
        items.push
          isDivider: false
          id: friend.id
          name: friend.name
          username: friend.username
          imageUrl: friend.imageUrl
      items.push
        isDivider: true
        title: 'Contacts'
      @items = items
    , =>
      @fbFriendsRequestError = true

  done: ->
    @$state.go 'events'

  items: [
    isDivider: true
    title: 'Friends Using Down'
  ,
    isDivider: false
    id: 1
    name: 'Michael Kolodny'
    username: 'm'
    imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
  ,
    isDivider: false
    id: 2
    name: 'Andrew Linfoot'
    username: 'a'
    imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
  ,
    isDivider: true
    title: 'Contacts'
  ]

module.exports = FindFriendsCtrl
