class AddFromAddressBookCtrl
  constructor: (@$scope, @Contacts, localStorageService) ->
    @localStorage = localStorageService

    # Mock contacts for now.
    @items = [
      isDivider: true
      title: 'A'
    ,
      isDivider: false
      contact:
        name: 'Andrew Linfoot'
        phoneNumbers: [
          type: 'mobile'
          value: '3345678901'
          pref: true
        ]
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

    # TODO: Handle when the user hasn't saved their contacts yet.
    contacts = @localStorage.get 'contacts'
    if contacts isnt null
      @showContacts contacts
    else
      @isLoading = true
      @refresh()

  showContacts: (contacts) ->
    contactsArray = (contact for id, contact of contacts)
    contactsArray.sort (a, b) ->
      if a.name.toLowerCase() < b.name.toLowerCase()
        return -1
      else
        return 1
    @items = []
    currentLetter = null
    for contact in contactsArray
      if contact.name[0] != currentLetter
        @items.push
          isDivider: true
          title: contact.name[0]
        currentLetter = contact.name[0]

      if contact.user?.username
        @items.push
          isDivider: false
          user: contact.user
      else
        @items.push
          isDivider: false
          contact: contact

  refresh: ->
    refreshCompleteEvent = 'scroll.refreshComplete'
    @Contacts.getContacts().then (contacts) =>
      @showContacts contacts
      @$scope.$broadcast refreshCompleteEvent
      @loadError = false
    , =>
      @$scope.$broadcast refreshCompleteEvent
      @loadError = true
    .finally =>
      @isLoading = false

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

module.exports = AddFromAddressBookCtrl
