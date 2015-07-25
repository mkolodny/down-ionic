class Auth
  constructor: (@$http, @$q, @apiRoot, @Invitation, @User, @$cordovaGeolocation,
                @$state) ->

  user: {}

  friends: {}

  isAuthenticated: ->
    deferred = @$q.defer()

    @$http.get "#{@apiRoot}/users/me"
      .success (data, status) ->
        deferred.resolve true
      .error (data, status) ->
        if status is 401
          deferred.resolve false
        else
          deferred.reject()

    deferred.promise

  ###*
   * Check verifcation code with the server
   *
   * @param  {String} phone
   * @param  {String} code
   * @return {Promise}
  ###
  authenticate: (phone, code) ->
    deferred = @$q.defer()

    params =
      phone: phone
      code: code

    @$http.post "#{@apiRoot}/sessions", params
      .success (data, status) =>
        @user = @User.deserialize data
        deferred.resolve @user
      .error (data, status) ->
        deferred.reject status

    deferred.promise

  syncWithFacebook: (accessToken) ->
    deferred = @$q.defer()

    @$http.post "#{@apiRoot}/social-account", {access_token: accessToken}
      .success (data, status) =>
        @user.email = data.email
        @user.name = data.name
        @user.imageUrl = data.image_url
        deferred.resolve @user
      .error (data, status) ->
        deferred.reject status

    deferred.promise

  sendVerificationText: (phone) ->
    @$http.post "#{@apiRoot}/authcodes", {phone: phone}
      .success (data, status) =>
        @phone = phone

  getInvitations: ->
    deferred = @$q.defer()

    @$http.get "#{@User.listUrl}/invitations"
      .success (data, status) =>
        invitations = (@Invitation.deserialize invitation for invitation in data)
        deferred.resolve invitations
      .error (data, status) =>
        deferred.reject()

    deferred.promise

  isFriend: (userId) ->
    @friends[userId]?

  watchLocation: ->
    deferred = @$q.defer()

    @$cordovaGeolocation.watchPosition().then null
      , (error) =>
        if error.code is 'PositionError.PERMISSION_DENIED'
          @$state.go 'requestLocation'
          deferred.reject()
        else
          deferred.resolve()

      , (position) =>
        deferred.resolve()

        location =
          lat: position.coords.latitude
          long: position.coords.longitude
        @updateLocation location

    deferred.promise

  updateLocation: (location) ->
    user = angular.copy @user
    user.location = location
    @User.update(user).$promise.then (user) =>
      @user = user

module.exports = Auth
