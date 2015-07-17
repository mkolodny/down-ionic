class Auth
  constructor: (@$http, @$q, @apiRoot, @User) ->

  user: {}

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

  authenticate: (authData) ->
    deferred = @$q.defer()

    @$http.post "#{@apiRoot}/sessions", authData
      .success (data, status) =>
        @user = @User.deserialize data
        deferred.resolve @user
      .error (data, status) ->
        deferred.reject()

    deferred.promise

  syncWithFacebook: (syncData) ->
    deferred = @$q.defer()

    @$http.post "#{@apiRoot}/social-account", syncData
      .success (data, status) =>
        @user.email = data.email
        @user.name = data.name
        @user.imageUrl = data.image_url
        deferred.resolve @user
      .error (data, status) ->
        deferred.reject()

    deferred.promise

module.exports = Auth
