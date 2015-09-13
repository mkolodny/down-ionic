require '../../vendor/intl-phone/libphonenumber-utils.js'

class Contacts
  @$inject: ['$http', '$cordovaContacts', '$q', 'Auth', 'localStorageService'
             'UserPhone']
  constructor: (@$http, @$cordovaContacts, @$q, @Auth, localStorageService,
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
      .then (users) =>
        @saveContacts users
        @localStorage.set 'hasRequestedContacts', true
        deferred.resolve users
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
   *                         name: {
   *                           formatted: <String>,
   *                         },
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
    # username; mobile #; whatever
    contactIds = {}
    for id, contact of contacts
      for phoneNumber in contact.phoneNumbers
        phone = phoneNumber.value
        contactIds[phone] = contact.id

    deferred = @$q.defer()
    @getContactUsers contacts
      .then (userPhones) =>
        users = {}
        for userPhone in userPhones
          user = userPhone.user
          users[user.id] = user
        deferred.resolve users
      , ->
        deferred.reject()
    deferred.promise

  contactArrayToDict: (contacts) ->
    contactsObject = {}
    for contact in contacts
      contactsObject[contact.id] = contact
    contactsObject

  getContactUsers: (contacts) ->
    contactPhones = []
    for id, contact of contacts
      for phoneNumber in contact.phoneNumbers
        contactPhones.push
          name: contact.name.formatted
          phone: phoneNumber.value
    @UserPhone.getFromContacts(contactPhones).$promise

  filterContacts: (contacts) ->
    filteredContacts = []
    phones = {}
    for contact in contacts
      if contact.name.formatted and contact.phoneNumbers?.length > 0
        # Make sure the contact isn't the current user.
        phoneNumbers = (phoneNumber.value for phoneNumber in contact.phoneNumbers)
        if @Auth.phone in phoneNumbers
          continue

        unique = true
        for phoneNumber in phoneNumbers
          # Make sure the contact is unique.
          if phones[phoneNumber]
            unique = false
          phones[phoneNumber] = true

        if not unique
          continue

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

    filteredNumbers = {}
    for number in numbers
      if intlTelInputUtils.isValidNumber number.value
        filteredNumbers[number.value] = number
    (number for value, number of filteredNumbers)

  saveContacts: (contacts) ->
    @localStorage.set 'contacts', contacts

module.exports = Contacts
