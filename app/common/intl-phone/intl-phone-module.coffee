require './intlTelInput.js'
intlPhone = require './intl-phone-directive'

angular.module 'rallytap.intlPhone', []
  .directive 'intlPhone', intlPhone
