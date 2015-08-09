class Contacts
  constructor: (localStorageService, @$http, @Auth, @$cordovaContacts, @UserPhone,
                @$q) ->
    @localStorage = localStorageService
    @i18n = window.intlTelInputUtils

  getContacts: ->
    @localStorage.set 'hasRequestedContacts', true

    fields = ['id', 'name', 'phoneNumbers']

    deferred = @$q.defer()

    @$cordovaContacts.find fields
      .then (contacts) =>
        contacts = @filterContacts contacts
        for contact in contacts
          phoneNumbers = contact.phoneNumbers
          phoneNumbers = @filterNumbers phoneNumbers
          phoneNumbers = @formatNumbers phoneNumbers
        @identifyContacts contacts
          .then (contactsObject) =>
            @saveContacts contactsObject
            deferred.resolve contactsObject
          , ->
            error =
              code: 'IDENTIFY_FAILED'
            deferred.reject error
      , (error) ->
        deferred.reject error

    return deferred.promise

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
        # TODO : save users in localStorage
        deferred.resolve contactsObject
      , ->
        deferred.reject()

    return deferred.promise

  contactArrayToObject: (contacts) ->
    contactsObject = {}
    for contact in contacts
      contactId = contact.id
      contactsObject[contactId] = contact
    return contactsObject

  mapContactIds: (contacts) ->
    contactsIdMap = {}
    for contact in contacts
      contactId = contact.id
      for phoneNumber in contact.phoneNumbers
        phone = phoneNumber.value
        contactsIdMap[phone] = contactId
    return contactsIdMap

  getContactUsers: (contacts) ->
    phones = []
    for contact in contacts
      for phoneNumber in contact.phoneNumbers
        phones.push phoneNumber.value
    return @UserPhone.getFromPhones(phones).$promise

  filterContacts: (contacts) ->
    filteredContacts = []
    for contact in contacts
      if contact.name.formatted.length is 0
        continue
      filteredContacts.push contact
    return filteredContacts

  filterNumbers: (numbers) ->
    filteredNumbers = []
    for number in numbers
      if @i18n.isValidNumber number.value
        filteredNumbers.push number
    return filteredNumbers

  formatNumbers: (numbers) ->
    E164 = @i18n.numberFormat.E164
    countryCode = @i18n.getCountryCode @Auth.phone
    for number in numbers
      number.value = @i18n.formatNumberByType number.value, countryCode, E164
    return numbers

  saveContacts: (contacts) ->
    @localStorage.set 'contacts', contacts

module.exports = Contacts
