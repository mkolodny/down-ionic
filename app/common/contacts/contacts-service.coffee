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
      .then (contactsArray) =>
        for contact in contactsArray
          contact.phoneNumbers = @formatNumbers contact.phoneNumbers
          contact.phoneNumbers = @filterNumbers contact.phoneNumbers
        contactsArray = @filterContacts contactsArray
        contactsDict = @contactArrayToDict contactsArray

        @identifyContacts contactsDict
      , (error) =>
        deferred.reject error
      .then (contactsDict) =>
        @saveContacts contactsDict
        @localStorage.set 'hasRequestedContacts', true
        deferred.resolve contactsDict
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
    # Create a dictionary in the format: {phone: contactId, ...}
    contactIdsDict = {}
    for id, contact of contacts
      for phoneNumber in contact.phoneNumbers
        phone = phoneNumber.value
        contactIdsDict[phone] = contact.id

    deferred = @$q.defer()
    @getContactUsers contacts
      .then (userPhones) =>
        for userPhone in userPhones
          contactId = contactIdsDict[userPhone.phone]
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
    for id, contact of contacts
      for phoneNumber in contact.phoneNumbers
        phones.push phoneNumber.value
    @UserPhone.getFromPhones(phones).$promise

  filterContacts: (contacts) ->
    filteredContacts = []
    for contact in contacts
      if contact.name.formatted and contact.phoneNumbers?.length > 0
        filteredContacts.push contact
    filteredContacts

  formatNumbers: (numbers) ->
    if numbers is null
      return null

    E164 = intlTelInputUtils.numberFormat.E164
    countryCode = intlTelInputUtils.getCountryCode @Auth.phone
    for number in numbers
      number.value = intlTelInputUtils.formatNumberByType number.value,
          countryCode, E164
    numbers

  filterNumbers: (numbers) ->
    if numbers is null
      return []

    filteredNumbers = []
    for number in numbers
      if intlTelInputUtils.isValidNumber number.value
        filteredNumbers.push number
    filteredNumbers

  saveContacts: (contacts) ->
    @localStorage.set 'contacts', contacts

module.exports = Contacts
