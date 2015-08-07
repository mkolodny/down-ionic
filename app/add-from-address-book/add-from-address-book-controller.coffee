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
      contact:
        user:
          id: 1
          name: 'Michael Kolodny'
          username: 'm'
          imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
        name: 'Michael Kolodny'
        phoneNumbers: [
          type: 'mobile'
          value: '3345678901'
          pref: true
        ]
    ]
    return

    contacts = @localStorage.get 'contacts'
    @showContacts contacts

  showContacts: (contacts) ->
    contactsArray = []
    for id, contact of contacts
      contactsArray.push contact
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
