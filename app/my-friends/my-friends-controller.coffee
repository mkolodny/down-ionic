require '../vendor/intl-phone/libphonenumber-utils.js'

class MyFriendsCtrl
  # TODO: Handle when the user's friends aren't saved yet. We have to update the
  #   friends' locations somehow.
  @$inject: ['$ionicHistory', '$state', 'Auth']
  constructor: (@$ionicHistory, @$state, @Auth) ->
    friends = angular.copy @Auth.user.friends

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
    phoneNameItems = []
    currentLetter = null
    for friend in friends
      firstLetter = friend.name[0]
      if firstLetter != currentLetter and \
         firstLetter isnt '+'
        alphabeticalItems.push
          isDivider: true
          title: friend.name[0]
        currentLetter = friend.name[0]

      if firstLetter is '+'
        # Add friends with phone
        #   numbers for names at the end
        phoneNameItems.push
          isDivider: false
          friend: friend
      else
        alphabeticalItems.push
          isDivider: false
          friend: friend

    # Add friends with a phone number for a
    #   name to the end of the friends list
    if phoneNameItems.length > 0
      alphabeticalItems.push
        isDivider: true
        title: 'Added by phone #'
      alphabeticalItems = alphabeticalItems.concat phoneNameItems

    # Build the list of items to show in the collection.
    @items = []
    if @nearbyFriends.length > 0
      @items.push
        isDivider: true
        title: 'Nearby Friends'
    for friend in @nearbyFriends
      @items.push
        isDivider: false
        friend: friend
    for item in alphabeticalItems
      @items.push item

    # Save the user's phone number for formatting phones.
    @myPhone = @Auth.phone

  getInitials: (name) ->
    words = name.split ' '
    firstName = words[0]
    if words.length is 1 and firstName.length > 1 # Their name is only one word.
      initials = "#{firstName[0]}#{firstName[1]}"
    else if words.length is 1 # Their name is only one letter.
      initials = firstName[0]
    else # Their name has multiple words.
      words.reverse()
      lastName = words[0]
      initials = "#{firstName[0]}#{lastName[0]}"
    initials.toUpperCase()

  addFriends: ->
    @$ionicHistory.nextViewOptions
      disableAnimate: true
    @$state.go 'tabs.friends.addFriends'

  isPhone: (name) ->
    name[0] is '+' and intlTelInputUtils.isValidNumber name

module.exports = MyFriendsCtrl
