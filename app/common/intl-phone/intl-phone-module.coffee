require './intlTelInput.js'
intlPhoneDirective = require './intl-phone-directive'
formatPhoneFilter = require './format-phone-filter'

angular.module 'rallytap.intlPhone', []
  .directive 'intlPhone', intlPhoneDirective
  .filter 'formatPhone', formatPhoneFilter
