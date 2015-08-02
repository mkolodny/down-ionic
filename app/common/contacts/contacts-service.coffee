class Contacts
  constructor: (localStorageService, @$http, @Auth, @$cordovaContacts, @UserPhone) ->
    @localStorage = localStorageService
    @i18n = window.intlTelInputUtils

  getContacts: () ->
    @localStorage.set('hasRequestedContacts', true)

    fields = ['id', 'name', 'phoneNumbers']
    @$cordovaContacts.find(fields)

  identifyContacts: (contacts) ->
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
    # TODO : Use users country code
    for number in numbers
      number.value = @i18n.formatNumberByType(number.value, 'US', E164)
    return numbers

  saveContacts: (contacts) ->
    @localStorage.set 'contacts', contacts

module.exports = Contacts


# fields = ['name', 'phoneNumbers']
# -    @$cordovaContacts.find(fields)
# -      .then (contacts) =>
# -        @formatContacts(contacts)
# -      , (error) =>
# -        if error.code is 'ContactError.PERMISSION_DENIED_ERROR'
# -          @Auth.redirectForAuthState()