require 'angular'
require './intlTelInput.js'
intlPhone = require './intl-phone-directive'

angular.module 'down.intlPhone', []
  .directive 'intlPhone', intlPhone
