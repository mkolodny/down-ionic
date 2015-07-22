class AddFriendsSignupCtrl
  constructor: (@$state, @User) ->
    return # Use mock data for now.

    @User.getFacebookFriends().$promise.then (facebookFriends) =>
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

  friends: [
    isDivider: true
    title: 'Facebook Friends'
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

module.exports = AddFriendsSignupCtrl
