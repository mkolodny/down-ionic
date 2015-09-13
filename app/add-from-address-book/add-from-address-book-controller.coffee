class AddFromAddressBookCtrl
  @$inject: ['$scope', 'Contacts', 'localStorageService', 'User']
  constructor: (@$scope, @Contacts, localStorageService, @User) ->
    @localStorage = localStorageService

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
      firstLetter = contact.name[0].toUpperCase()
      if firstLetter != currentLetter
        @items.push
          isDivider: true
          title: firstLetter
        currentLetter = firstLetter

      if contact.username isnt null
        @items.push
          isDivider: false
          user: new @User contact
      else
        @items.push
          isDivider: false
          contact: contact

  refresh: ->
    refreshCompleteEvent = 'scroll.refreshComplete'
    @Contacts.getContacts()
      .then (contacts) =>
        @showContacts contacts
        @$scope.$broadcast refreshCompleteEvent
        @getContactsError = false
      , =>
        @$scope.$broadcast refreshCompleteEvent
        @getContactsError = true
      .finally =>
        @isLoading = false

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

module.exports = AddFromAddressBookCtrl
