require 'angular'
require 'angular-mocks'
window.$ = window.jQuery = require 'jquery'
require './intl-phone-module'

fdescribe 'format phone filter', ->
  formatPhone = null

  beforeEach angular.mock.module('rallytap.intlPhone')

  beforeEach inject(($injector) ->
    formatPhone = $injector.get 'formatPhoneFilter'
  )

  describe 'formatting a phone', ->
    formattedPhone = null

    beforeEach ->
      phone = '+19178233560'
      standardPhone = '+19178333560'
      formattedPhone = formatPhone phone, standardPhone

    it 'should return the formatted phone', ->
      expect(formattedPhone).toBe '(917) 823-3560'
