class AddFromAddressBookCtrl
  @$inject: ['$scope', 'Contacts', 'LocalDB', 'User']
  constructor: (@$scope, @Contacts, @LocalDB, @User) ->

    @LocalDB.get('contacts').then (contactsObject) =>
      if contactsObject isnt null
        @showContacts contactsObject
      else
        @isLoading = true
        @refresh()
    , =>
      @getContactsError = true

  showContacts: (contacts) ->
    contactsArray = (contact for id, contact of contacts)
    for contact in contactsArray
      contact.name = contact.name.trim()
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

      @items.push
        isDivider: false
        user: new @User contact

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

module.exports = AddFromAddressBookCtrl
