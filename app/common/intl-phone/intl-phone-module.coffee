# require './intlTelInput.js' bundles with resources plugin or injected from CDN
intlPhoneDirective = require './intl-phone-directive'
formatPhoneFilter = require './format-phone-filter'

angular.module 'rallytap.intlPhone', []
  .directive 'intlPhone', intlPhoneDirective
  .filter 'formatPhone', formatPhoneFilter
