class Contacts
  constructor: (localStorageService, @$http) ->
    @localStorage = localStorageService
    # Make sure intlTelInputUtils are loaded?
    @$http.get 'app/vendor/intl-phone/libphonenumber-utils.js'

  formatContacts: (contacts) ->
    forattedContacts = []
    for contact in contacts

      formattedPhoneNumbers = []
      for contactField in contact?.phoneNumbers
        phoneNumber = contactField.value
        # Check if valid phone number
        if intlTelInputUtils.isValidNumber(phoneNumber)
          # Overright with E164 formatted version
          contactField.value = intlTelInputUtils.formatE164(phoneNumber)
          # Only return valid phone numbers for each contact
          formattedPhoneNumbers.push phoneNumber
      contact.phoneNumbers = formattedPhoneNumbers

      if contact.phoneNumbers.length > 0
        formatContacts.push contact

    return formatContacts

module.exports = Contacts
