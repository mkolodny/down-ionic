class RequestContactsCtrl
  constructor: (localStorageService, @$cordovaContacts, @Auth) ->
    @localStorage = localStorageService

  requestContacts: () ->
    @localStorage.set 'hasRequestedContacts', true

    fields = ['name', 'phoneNumbers']
    @$cordovaContacts.find(fields)
      .then (contacts) =>
        @formatContacts(contacts)
      , (error) =>
        if error.code is 'ContactError.PERMISSION_DENIED_ERROR'
          @Auth.redirectForAuthState()
        

  formatContacts: (contacts) ->


module.exports = RequestContactsCtrl
