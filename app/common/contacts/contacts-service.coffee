class Contacts
  constructor: (localStorageService, @$http, @Auth) ->
    @localStorage = localStorageService
    @i18n = window.intlTelInputUtils

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

module.exports = Contacts
