Friendship = ['$http', '$meteor', '$q', '$resource', 'apiRoot', 'Auth', \
              ($http, $meteor, $q, $resource, apiRoot, Auth) ->
  listUrl = "#{apiRoot}/friendships"

  resource = $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          user: data.userId
          friend: data.friendId
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          userId: data.user
          friendId: data.friend
        response

  resource.deleteWithFriendId = (friendId) ->
    deferred = $q.defer()

    $http
      method: 'delete'
      url: "#{listUrl}/friend"
      data:
        friend: friendId
      headers:
        'Content-Type': 'application/json;charset=utf-8'
    .success (data, status, headers, config) ->
      deferred.resolve()
    .error (data, status, headers, config) ->
      deferred.reject()

    {$promise: deferred.promise}

  resource.sendMessage = (friend, text) ->
    friendId = friend.id
    # Save the message on the meteor server.
    Messages = $meteor.getCollectionByName 'messages'
    Messages.insert
      creator:
        id: "#{Auth.user.id}" # Meteor likes strings
        name: Auth.user.name
        firstName: Auth.user.firstName
        lastName: Auth.user.lastName
        imageUrl: Auth.user.imageUrl
      text: text
      chatId: @getChatId friendId
      type: 'text'
      createdAt: new Date()

  resource.getChatId = (friendId) ->
    if Auth.user.id < friendId
      "#{Auth.user.id},#{friendId}"
    else
      "#{friendId},#{Auth.user.id}"

  resource.parseChatId = (chatId) ->
    ids = chatId.split ','
    if ids[0] is "#{Auth.user.id}"
      ids[1]
    else
      ids[0]

  ##
  # options:
  # {
  #   query: String
  #   contacts: Bool - Not implemented yet
  #   facebookFriends: Bool - Not implemented yet
  #   phoneNames: Bool - Not implemented yet
  # }
  ##
  resource.buildFriendItems = (options = {}) ->
    items = []
    if options.query
      # Only show unique users.
      friendsDict = {}
      for id, friend of Auth.user.friends

        # Filter out friends who have phone numbers as names
        firstLetter = friend.name[0]
        if firstLetter is '+' then continue

        friendsDict[id] = friend
      for id, friend of Auth.user.facebookFriends
        friendsDict[id] = friend
      # for id, contact of contacts
      #   friendsDict[id] = contact
      friends = (friend for id, friend of friendsDict \
          when friend.name.toLowerCase().indexOf(options.query.toLowerCase()) isnt -1)
      friends.sort (a, b) ->
        if a.name.toLowerCase() < b.name.toLowerCase()
          return -1
        else
          return 1

      items = ({isDivider: false, friend: friend} \
          for friend in friends)
    else
      # Build the list of alphabetically sorted nearby friends.
      nearbyFriends = (friend for id, friend of Auth.user.friends \
          when Auth.isNearby friend)
      nearbyFriends.sort (a, b) ->
        if a.name.toLowerCase() < b.name.toLowerCase()
          return -1
        else
          return 1

      # Build the list of alphabetically sorted items.
      friends = (friend for id, friend of Auth.user.friends)
      friends.sort (a, b) ->
        if a.name.toLowerCase() < b.name.toLowerCase()
          return -1
        else
          return 1
      alphabeticalItems = []
      currentLetter = null
      for friend in friends
        firstLetter = friend.name[0]

        # Filter out friends who have phone numbers as names
        if firstLetter is '+' then continue

        if firstLetter != currentLetter
          alphabeticalItems.push
            isDivider: true
            title: friend.name[0]
          currentLetter = friend.name[0]

        alphabeticalItems.push
          isDivider: false
          friend: friend

      # Build the list of facebook friends.
      facebookFriends = (friend for id, friend of Auth.user.facebookFriends)
      facebookFriends.sort (a, b) ->
        if a.name.toLowerCase() < b.name.toLowerCase()
          return -1
        else
          return 1
      facebookFriendsItems = ({isDivider: false, friend: friend} \
          for friend in facebookFriends)

      # Build the list of contacts.
      # contacts = (contact for id, contact of contacts)
      # contacts.sort (a, b) ->
      #   if a.name.toLowerCase() < b.name.toLowerCase()
      #     return -1
      #   else
      #     return 1
      # contactsItems = ({isDivider: false, friend: friend} \
      #     for friend in contacts)

      # Build the list of items to show in the collection.
      if nearbyFriends.length > 0
        items.push
          isDivider: true
          title: 'Nearby Friends'
      for friend in nearbyFriends
        items.push
          isDivider: false
          friend: friend
      for item in alphabeticalItems
        items.push item
      if facebookFriendsItems.length > 0
        items.push
          isDivider: true
          title: 'Facebook Friends'
      for item in facebookFriendsItems
        items.push item
      # if contactsItems.length > 0
      #   items.push
      #     isDivider: true
      #     title: 'Contacts'
      # for item in contactsItems
      #   items.push item

    items

  resource
]

module.exports = Friendship
