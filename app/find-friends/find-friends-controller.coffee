class FindFriendsCtrl
  @$inject: ['$ionicLoading', '$scope', '$state', 'Auth', 'Contacts',
             'localStorageService', 'User']
  constructor: (@$ionicLoading, @$scope, @$state, @Auth, @Contacts,
                localStorageService, @User) ->
    @localStorage = localStorageService

    # Request Contacts Permission
    @isLoading = true
    @$scope.$on '$ionicView.enter', =>
      @$ionicLoading.show
        template: '''
          <div class="loading-text" id="loading-contacts">Loading your contacts...<br>(This might take a while)</div>
          <ion-spinner icon="bubbles"></ion-spinner>
          '''

      @Contacts.getContacts()
        .then (contacts) =>
          @items = @buildItems @Auth.user.facebookFriends, contacts
        , (error) =>
          if error.code is 'PERMISSION_DENIED_ERROR'
            @contactsDeniedError = true
          else
            @contactsRequestError = true
        .finally =>
          @isLoading = false
          @$ionicLoading.hide()

    # Build the list of items to show in the view.
    @items = @buildItems @Auth.user.facebookFriends

  buildItems: (facebookFriends, contactsDict = {}) ->
    # Create a separate array of users with usernames, and one with contacts (who
    #   don't have usernames). Make sure the users are unique.
    users = (friend for id, friend of facebookFriends)
    contacts = []
    for id, contact of contactsDict
      if angular.isDefined facebookFriends[contact.id]
        continue
      if contact.username isnt null
        users.push contact
      else
        contacts.push contact

    items = []

    # Only show the "Friends Using Down" divider when the user has friends using
    #   Down.
    if users.length > 0
      items.push
        isDivider: true
        title: 'Friends Using Down'
      users.sort (a, b) ->
        if a.name.toLowerCase() < b.name.toLowerCase()
          return -1
        else
          return 1
      for user in users
        items.push
          isDivider: false
          user: user

    # Only show the "Contacts" divider when the user's contacts have been
    #   returned.
    if contacts.length > 0
      items.push
        isDivider: true
        title: 'Contacts'
      contacts.sort (a, b) ->
        if a.name.toLowerCase() < b.name.toLowerCase()
          return -1
        else
          return 1
      for contact in contacts
        items.push
          isDivider: false
          user: contact

    # Give each item an id so that we can use `track by` for performance.
    for item in items
      if item.isDivider
        item.id = item.title
      else
        item.id = item.user.id

    items

  getInitials: (name) ->
    words = name.split ' '
    firstName = words[0]
    if (words.length is 1 or words[1] is '') and firstName.length > 1
      # Their name is only one word.
      initials = "#{firstName[0]}#{firstName[1]}"
    else if (words.length is 1 or words[1] is '') # Their name is only one letter.
      initials = firstName[0]
    else # Their name has multiple words.
      words.reverse()
      lastName = words[0]
      initials = "#{firstName[0]}#{lastName[0]}"
    initials.toUpperCase()

  done: ->
    @localStorage.set 'hasCompletedFindFriends', true
    @Auth.redirectForAuthState()

  search: (item) =>
    console.log item.id
    if not @query
      return true

    if item.isDivider
      return false

    item.user.name.toLowerCase().indexOf(@query.toLowerCase()) isnt -1

module.exports = FindFriendsCtrl
