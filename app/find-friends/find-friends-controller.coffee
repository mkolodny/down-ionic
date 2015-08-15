class FindFriendsCtrl
  constructor: (@$ionicLoading, @$scope, @$state, @Auth, @User,
                localStorageService, @Contacts) ->
    @localStorage = localStorageService

    # Request Contacts Permission
    @isLoading = true
    @$scope.$on '$ionicView.enter', =>
      @$ionicLoading.show
        template: '''
          <div class="loading-text" id="loading-contacts">Loading your contacts...<br>(This might take a while)</div>
          <ion-spinner icon="bubbles"></ion-spinner>
          '''

      @Contacts.getContacts().then null, =>
        @contactsRequestError = true
      , (contacts) =>
        @items = @buildItems @Auth.user.facebookFriends, contacts
      .finally =>
        @isLoading = false

    # Build the list of items to show in the view.
    @items = @buildItems @Auth.user.facebookFriends

  buildItems: (facebookFriends, contacts = {}) ->
    # Create a separate array of contacts who aren't users, and contacts who are
    #   users.
    contacts = (contact for id, contact of contacts)
    users = (contact.user for contact in contacts when contact.user?.username)
    contacts = (contact for contact in contacts when not contact.user?.username)

    # Merge the user's facebook friends with the user's contacts who are Down
    #   users.
    users = facebookFriends.concat users

    items = []
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
    if contacts.length is 0
      # Don't show the "Contacts" divider when there are no contacts yet.
      return items
    items.push
      isDivider: true
      title: 'Contacts'
    contacts.sort (a, b) ->
      if a.name.formatted.toLowerCase() < b.name.formatted.toLowerCase()
        return -1
      else
        return 1
    for contact in contacts
      items.push
        isDivider: false
        contact: contact
    items

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

  done: ->
    @localStorage.set 'hasCompletedFindFriends', true
    @Auth.redirectForAuthState()

module.exports = FindFriendsCtrl
