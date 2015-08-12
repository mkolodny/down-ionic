require '../../vendor/intl-phone/libphonenumber-utils.js'

UserPhone = ($http, $q, $resource, apiRoot, Auth, localStorageService, User) ->
  listUrl = "#{apiRoot}/userphones"

  resource = $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          user: User.serialize data.user
          phone: data.phone
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response =
          id: data.id
          user: User.deserialize data.user
          phone: data.phone
        response

    getFromPhones:
      method: 'post'
      url: "#{listUrl}/phones"
      isArray: true
      transformRequest: (data, headersGetter) ->
        request = {phones: data}
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        response = ({
          user: User.deserialize userphone.user
          phone: userphone.phone
        } for userphone in data)
        response

  resource.create = (contact) ->
    deferred = $q.defer()

    # Get the contact's preferred phone number, formatted accorded to the current
    #   user's country code. `intlTelInputUtils` is on the window object from
    #   libphonenumber-utils.
    # TODO: Validate the number.
    phone = contact.phoneNumbers[0].value
    countryCode = intlTelInputUtils.getCountryCode Auth.phone
    intlPhone = intlTelInputUtils.formatNumberByType phone, countryCode,
        intlTelInputUtils.numberFormat.E164

    requestData =
      name: contact.name
      phone: intlPhone
    $http.post "#{listUrl}/contact", requestData
      .success (data, status) ->
        userphone = data
        userphone.user = User.deserialize data.user

        # Update the contact in local storage.
        contacts = localStorageService.get 'contacts'
        contact.user = userphone.user
        contacts[contact.id] = contact
        localStorageService.set 'contacts', contacts

        response =
          contact: contact
          userphone: userphone
        deferred.resolve response
      .error (data, status) ->
        deferred.reject()

    deferred.promise

  resource

module.exports = UserPhone
