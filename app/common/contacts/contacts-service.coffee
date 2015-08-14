require '../../vendor/intl-phone/libphonenumber-utils.js'

class Contacts
  constructor: (@$q, @$http, @$cordovaContacts, @Auth, localStorageService,
                @UserPhone) ->
    @localStorage = localStorageService

  getContacts: ->
    deferred = @$q.defer()

    options =
      filter: ''
      multiple: true
      fields: [
        'id'
        'name'
        'phoneNumbers'
      ]
    @$cordovaContacts.find options
      .then (contacts) =>
        contacts = @filterContacts contacts
        contacts = @contactArrayToDict contacts
        @saveContacts contacts
        @localStorage.set 'hasRequestedContacts', true
        deferred.notify contacts

        @identifyContacts contacts
      , (error) =>
        @localStorage.set 'hasRequestedContacts', true
        deferred.reject error
      .then (contacts) =>
        # The contacts were just identified. `contacts` is a dictionary with
        #   contact ids mapped to Cordova contact objects.
        @saveContacts contacts
        deferred.notify contacts
        deferred.resolve()
      , ->
        error =
          code: 'IDENTIFY_FAILED'
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
    # Create an dictionary in the format: {phone: contactId, ...}
    contactsIdMap = {}
    for id, contact of contacts
      for phoneNumber in contact.phoneNumbers
        phone = phoneNumber.value
        contactsIdMap[phone] = contact.id
    contactsIdMap

    deferred = @$q.defer()
    @getContactUsers(contacts).then (userPhones) =>
      for userPhone in userPhones
        contactId = contactsIdMap[userPhone.phone]
        contacts[contactId].user = userPhone.user
      deferred.resolve contacts
    , ->
      deferred.reject()
    deferred.promise

  contactArrayToDict: (contacts) ->
    contactsObject = {}
    for contact in contacts
      contactsObject[contact.id] = contact
    contactsObject

  getContactUsers: (contacts) ->
    phones = []
    for contact in contacts
      for phoneNumber in contact.phoneNumbers
        phones.push phoneNumber.value
    @UserPhone.getFromPhones(phones).$promise

  filterContacts: (contacts) ->
    filteredContacts = []
    for contact in contacts
      if contact.phoneNumbers is null then continue
      phone = contact.phoneNumbers[0].value
      countryCode = intlTelInputUtils.getCountryCode @Auth.phone
      isValidNumber = intlTelInputUtils.isValidNumber phone, countryCode
      if contact.name.formatted.length > 0 and isValidNumber
        filteredContacts.push contact
    filteredContacts

  saveContacts: (contacts) ->
    @localStorage.set 'contacts', contacts

module.exports = Contacts
