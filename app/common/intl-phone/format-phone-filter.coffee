require '../../vendor/intl-phone/libphonenumber-utils.js'

formatPhoneFilter = ->
  (phone, standardPhone) ->
    countryCode = intlTelInputUtils.getCountryCode standardPhone
    national = intlTelInputUtils.numberFormat.NATIONAL
    intlTelInputUtils.formatNumberByType phone, countryCode, national

module.exports = formatPhoneFilter
