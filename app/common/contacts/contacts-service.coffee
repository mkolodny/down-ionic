class Contacts
  constructor: (@$q, @$http, @$cordovaContacts, @Auth, localStorageService,
                @UserPhone) ->
    @localStorage = localStorageService

  getContacts: ->
    @localStorage.set 'hasRequestedContacts', true

    fields = ['id', 'name', 'phoneNumbers']

    deferred = @$q.defer()

    @$cordovaContacts.find(fields).then (contacts) =>
      contacts = @filterContacts contacts
      @identifyContacts(contacts).then (contactsObject) =>
        @saveContacts contactsObject
        deferred.resolve contactsObject
      , ->
        error =
          code: 'IDENTIFY_FAILED'
        deferred.reject error
    , (error) ->
      deferred.reject error

    deferred.promise

  identifyContacts: (contacts) ->
    contactsObject = @contactArrayToObject contacts
    contactsIdMap = @mapContactIds contacts
    deferred = @$q.defer()
    @getContactUsers contacts
      .then (userPhones) =>
        for userPhone in userPhones
          phone = userPhone.phone
          userId = userPhone.user.id
          contactId = contactsIdMap[phone]
          contactsObject[contactId].userId = userId
        deferred.resolve contactsObject
      , ->
        deferred.reject()

    deferred.promise

  contactArrayToObject: (contacts) ->
    contactsObject = {}
    for contact in contacts
      contactId = contact.id
      contactsObject[contactId] = contact
    contactsObject

  mapContactIds: (contacts) ->
    contactsIdMap = {}
    for contact in contacts
      contactId = contact.id
      for phoneNumber in contact.phoneNumbers
        phone = phoneNumber.value
        contactsIdMap[phone] = contactId
    contactsIdMap

  getContactUsers: (contacts) ->
    phones = []
    for contact in contacts
      for phoneNumber in contact.phoneNumbers
        phones.push phoneNumber.value
    @UserPhone.getFromPhones(phones).$promise

  filterContacts: (contacts) ->
    filteredContacts = []
    for contact in contacts
      if contact.name.formatted.length is 0
        continue
      filteredContacts.push contact
    filteredContacts

  saveContacts: (contacts) ->
    @localStorage.set 'contacts', contacts

module.exports = Contacts
