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
      @identifyContacts(contacts).then (contacts) =>
        @saveContacts contacts
        deferred.resolve contacts
      , ->
        error =
          code: 'IDENTIFY_FAILED'
        deferred.reject error
    , (error) ->
      deferred.reject error

    deferred.promise

  ###*
   * Check which of the user's contacts are Down users. If a contact is a Down
   * user, set their user object as a property on the contact object.
   *
   * @param {Object[]} contacts - The user's contacts, provided by Cordova.
   * @return {Promise} - Resolved with an object with the user's contacts in the
   *                     format - {
   *                       contactId: {
   *                         id: <String>,
   *                         name: <String>,
   *                         phoneNumbers: [
   *                           {
   *                             type: <String>, # e.g. 'home'
   *                             value: <String>, # e.g. 2345678901
   *                             pref: <Bool> # True if this is the preferred #
   *                           }
   *                         ]
   *                         user: <User>, # Optional
   *                       }
   *                     }
  ###
  identifyContacts: (contacts) ->
    contactsObject = @contactArrayToObject contacts
    contactsIdMap = @mapContactIds contacts
    deferred = @$q.defer()
    @getContactUsers(contacts).then (userPhones) =>
      for userPhone in userPhones
        contactId = contactsIdMap[userPhone.phone]
        contactsObject[contactId].user = userPhone.user
      deferred.resolve contactsObject
    , ->
      deferred.reject()
    deferred.promise

  contactArrayToObject: (contacts) ->
    contactsObject = {}
    for contact in contacts
      contactsObject[contact.id] = contact
    contactsObject

  mapContactIds: (contacts) ->
    contactsIdMap = {}
    for contact in contacts
      for phoneNumber in contact.phoneNumbers
        phone = phoneNumber.value
        contactsIdMap[phone] = contact.id
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
