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

  sendVerificationText: (phoneData) ->
     @$http.post "#{@apiRoot}/authcodes", phoneData

module.exports = Auth
