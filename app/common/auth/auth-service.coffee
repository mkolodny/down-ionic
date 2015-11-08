haversine = require 'haversine'

class Auth
  @$inject: ['$http', '$q', '$meteor', '$mixpanel', 'apiRoot', 'User',
             '$cordovaGeolocation', '$state', 'LocalDB']
  constructor: (@$http, @$q, @$meteor, @$mixpanel, @apiRoot, @User,
                @$cordovaGeolocation, @$state, @LocalDB) ->

  user: {}

  flags: {}

  resumeSession: ->
    deferred = @$q.defer()

    @LocalDB.get 'session'
      .then (session) =>
        if not session
          deferred.resolve()

        @phone = session.phone
        @flags = session.flags or {}
        @user = new @User session.user

        # Set friends as instances of User resource
        if angular.isDefined @user.friends
          for id, friend of @user.friends
            @user.friends[id] = new @User friend
        if angular.isDefined @user.facebookFriends
          for id, friend of @user.facebookFriends
            @user.facebookFriends[id] = new @User friend

        # re-establish Meteor auth
        if angular.isDefined @user.authtoken
          @$meteor.loginWithPassword "#{@user.id}", @user.authtoken

        @mixpanelIdentify()

        deferred.resolve()
      , (error) ->
        deferred.reject()

    deferred.promise

  saveSession: ->
    deferred = @$q.defer()

    session =
      flags: @flags
      user: @user
      phone: @phone

    @LocalDB.set 'session', session
      .then ->
        deferred.resolve()
      , ->
        deferred.reject()

    deferred.promise

  mixpanelIdentify: ->
    #identify and set user data with mixpanel
    @$mixpanel.identify @user.id
    if angular.isDefined @user.name
      @$mixpanel.people.set {$name: @user.name}
    if angular.isDefined @user.email
      @$mixpanel.people.set {$email: @user.email}
    if angular.isDefined @user.username
      @$mixpanel.people.set {$username: @user.username}

  setUser: (user) ->
    @user = angular.extend @user, user
    @mixpanelIdentify()
    @saveSession()

  setPhone: (phone) ->
    @phone = phone
    @saveSession()

  setFlag: (flagKey, flagValue) ->
    @flags[flagKey] = flagValue
    @saveSession()

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

  getMe: ->
    deferred = @$q.defer()

    @$http.get "#{@apiRoot}/users/me"
      .success (data, status) =>
        user = @User.deserialize data
        deferred.resolve user
      .error (data, status) ->
        deferred.reject()

    deferred.promise

  ###*
   * Check verification code with the server
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

  facebookLogin: (accessToken) ->
    deferred = @$q.defer()

    @$http.post "#{@apiRoot}/sessions/facebook", {access_token: accessToken}
      .success (data, status) =>
        @user = @User.deserialize data
        deferred.resolve @user
      .error (data, status) ->
        deferred.reject status

    deferred.promise

  facebookSync: (accessToken) ->
    deferred = @$q.defer()

    @$http.post "#{@apiRoot}/social-account", {access_token: accessToken}
      .success (data, status) =>
        user = @User.deserialize data
        @setUser user
        deferred.resolve @user
      .error (data, status) ->
        deferred.reject status

    deferred.promise

  sendVerificationText: (phone) ->
    @$http.post "#{@apiRoot}/authcodes", {phone: phone}
      .success (data, status) =>
        @phone = phone

  isFriend: (userId) ->
    if @user.friends[userId]?
      return true
    else
      return false

  isNearby: (user) ->
    if user.location is undefined or \
       @user.location is undefined
      return false

    start =
      latitude: @user.location.lat
      longitude: @user.location.long
    end =
      latitude: user.location.lat
      longitude: user.location.long
    haversine(start, end, {unit: 'mile'}) <= 5

  redirectForAuthState: ->
    isIOS = ionic.Platform.isIOS()
    isAndroid = ionic.Platform.isAndroid()

    if @flags.hasViewedTutorial isnt true
      @$state.go 'tutorial'
    else if not @phone?
      @$state.go 'login'
    else if not @user?.id
      @$state.go 'verifyPhone'
    else if not @user.imageUrl?
      @$state.go 'facebookSync'
    else if not @user.username?
      @$state.go 'setUsername'
    else if @flags.hasRequestedLocationServices isnt true \
         and isIOS
      @$state.go 'requestLocation'
    else if @flags.hasRequestedPushNotifications isnt true \
         and isIOS
      @$state.go 'requestPush'
    else if @flags.hasRequestedContacts isnt true \
         and isIOS
      @$state.go 'requestContacts'
    else if @flags.hasCompletedFindFriends isnt true \
         and (isIOS or isAndroid)
      @$state.go 'findFriends'
    else
      @$state.go 'events'

  watchLocation: ->
    deferred = @$q.defer()

    @$cordovaGeolocation.watchPosition()
      .then null, (error) =>
        if error.code is 1 and ionic.Platform.isIOS()
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
      @setUser user

  getFriends: ->
    deferred = @$q.defer()

    @$http.get "#{@User.listUrl}/friends"
      .success (data, status) =>
        friendsArray = (@User.deserialize(user) for user in data)
        @user.friends = {}
        for friend in friendsArray
          @user.friends[friend.id] = friend
        @setUser @user
        deferred.resolve @user.friends
      .error (data, status) =>
        deferred.reject()

    {$promise: deferred.promise}

  getFacebookFriends: ->
    deferred = @$q.defer()

    @$http.get "#{@User.listUrl}/facebook-friends"
      .success (data, status) =>
        facebookFriendsArray = (@User.deserialize(user) for user in data)
        @user.facebookFriends = {}
        for friend in facebookFriendsArray
          @user.facebookFriends[friend.id] = friend
        @setUser @user
        deferred.resolve @user.facebookFriends
      .error (data, status) =>
        if status is 400
          deferred.reject 'MISSING_SOCIAL_ACCOUNT'
        deferred.reject()

    {$promise: deferred.promise}

  getAddedMe: ->
    deferred = @$q.defer()

    @$http.get "#{@User.listUrl}/added-me"
      .success (data, status) =>
        deferred.resolve (@User.deserialize(user) for user in data)
      .error (data, status) =>
        deferred.reject()

    {$promise: deferred.promise}

  getDistanceAway: (location) ->
    # Return null if either a user's location
    #   isn't set or the friend's location isn't set
    if location is undefined or \
       @user.location is undefined
      return null

    start =
      latitude: @user.location.lat
      longitude: @user.location.long
    end =
      latitude: location.lat
      longitude: location.long
    distanceAway = haversine start, end, {unit: 'mile'}
    fiveHundredFeet = .094697
    if distanceAway <= fiveHundredFeet
      '500 feet'
    else if fiveHundredFeet < distanceAway < 1.5
      '1 mile'
    else if fiveHundredFeet < distanceAway < 100
      miles = Math.round distanceAway
      "#{miles} miles"
    else
      'really far'

  getTeamRallytap: ->
    deferred = @$q.defer()

    @$http.get "#{@apiRoot}/sessions/teamrallytap"
      .success (data, status) =>
        deferred.resolve @User.deserialize(data)
      .error (data, status) =>
        deferred.reject()

    {$promise: deferred.promise}

module.exports = Auth
