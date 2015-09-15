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
      .then (contacts) =>
        for contact in contacts
          contact.phoneNumbers = @formatNumbers contact.phoneNumbers
          contact.phoneNumbers = @filterNumbers contact.phoneNumbers
        contacts = @filterContacts contacts

        @identifyContacts contacts
      , (error) =>
        # Overwrite the error for now with a single error message.
        error =
          code: 'PERMISSION_DENIED_ERROR'
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
    contactIds = {}
    for contact in contacts
      for phoneNumber in contact.phoneNumbers
        phone = phoneNumber.value
        contactIds[phone] = contact.id

    deferred = @$q.defer()
    @toUsers contacts
      .then (users) =>
        deferred.resolve users
      , ->
        deferred.reject()
    deferred.promise

  toUsers: (contacts) ->
    deferred = @$q.defer()

    contactPhones = []
    for contact in contacts
      for phoneNumber in contact.phoneNumbers
        contactPhones.push
          name: contact.name.formatted
          phone: phoneNumber.value

    @UserPhone.getFromContacts contactPhones
      .$promise.then (userPhones) =>
        userPhones = @filterUserPhones userPhones, contacts
        users = {}
        for userPhone in userPhones
          user = userPhone.user
          users[user.id] = user
        deferred.resolve users
      , ->
        deferred.reject()

    deferred.promise

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

  ###*
   * Return a single user for each contact. Prefer users with usernames, then
   * mobile phone numbers. If a contact has neither, select the first contact.
   *
   * @param {UserPhone[]} userphones - A userphone for each phone number in
                                       contacts.
   * @param {Object[]} contacts - A filtered array of contacts.
   * @return {User[]} - A single user for each contact.
  ###
  filterUserPhones: (userPhones, contacts) ->
    # Map each phone to its userphone.
    phonesUserPhones = {}
    for userPhone in userPhones
      phonesUserPhones[userPhone.phone] = userPhone

    # Map each contact to an array of objects, where each object contains one of
    #   the contact's userphones, and the second is the type of phone number it is.
    contactPhoneNumbers = {}
    for contact in contacts
      contactPhoneNumbers[contact.id] = (
          {userPhone: phonesUserPhones[phoneNumber.value], type: phoneNumber.type} \
          for phoneNumber in contact.phoneNumbers)

    # Filter the userphones.
    filteredUserPhones = []
    for contactId, phoneNumbers of contactPhoneNumbers
      selectedUserPhone = null

      for phoneNumber in phoneNumbers
        if phoneNumber.userPhone.user.username isnt null
          selectedUserPhone = phoneNumber.userPhone
          break

      if selectedUserPhone isnt null
        filteredUserPhones.push selectedUserPhone
        continue

      for phoneNumber in phoneNumbers
        if phoneNumber.type is 'mobile'
          selectedUserPhone = phoneNumber.userPhone

      if selectedUserPhone isnt null
        filteredUserPhones.push selectedUserPhone
        continue

      filteredUserPhones.push phoneNumbers[0].userPhone

    filteredUserPhones

  saveContacts: (contacts) ->
    @localStorage.set 'contacts', contacts

module.exports = Contacts
