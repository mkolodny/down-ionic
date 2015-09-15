intlPhone = ->
  replace: true
  require: 'ngModel'
  template: '<input type="tel">'
  link: (scope, element, attrs, model) ->
    # TODO: Test this.
    # Init the international tel input plugin on the element.
    element.intlTelInput
      utilsScript: 'https://d3r38ef3fjjz7g.cloudfront.net/vendor/libphonenumber-utils.js'

    model.$parsers.unshift (value) ->
      # Set the phone number on the model.
      phone = element.intlTelInput 'getNumber'
      model.$setViewValue phone
      phone

    model.$validators.validNumber = (modelValue, viewValue) ->
      if modelValue is '+15555555555'
        # Let the Apple test user through.
        return true
      element.intlTelInput 'isValidNumber'

    return

module.exports = intlPhone
