class AddByPhoneCtrl
  @$inject: ['$scope', '$timeout', 'Auth', 'UserPhone']
  constructor: (@$scope, @$timeout, @Auth, @UserPhone) ->
    @currentUser = @Auth.user

  search: (form) ->
    @friend = null
    if form.$valid
      @isSearching = true

      # Get user from phone number
      @UserPhone.save({phone: @phone}).$promise
        .then (userPhone) =>
          @isSearching = false
          if userPhone.phone is @phone
            @friend = userPhone.user
        , =>
          @isSearching = false
          @searchError = true
    else
      # Invalid phone, clear search
      @isSearching = false

module.exports = AddByPhoneCtrl
