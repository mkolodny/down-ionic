require '../vendor/intl-phone/libphonenumber-utils.js'

class AddByPhoneCtrl
  @$inject: ['$scope', '$timeout', 'Auth', 'UserPhone']
  constructor: (@$scope, @$timeout, @Auth, @UserPhone) ->
    @currentUser = @Auth.user
    @myPhone = @Auth.phone

  search: (form) ->
    @friend = null
    form.phone.$validate()
    if form.$valid
      @isSearching = true

      # Get user from phone number
      @UserPhone.save {phone: @phone}
        .$promise.then (userPhone) =>
          @isSearching = false
          if userPhone.phone is @phone
            @friend = userPhone.user
        , =>
          @isSearching = false
          @searchError = true
    else
      # Invalid phone, clear search
      @isSearching = false

  isPhone: (name) ->
    name[0] is '+' and intlTelInputUtils.isValidNumber name

module.exports = AddByPhoneCtrl
