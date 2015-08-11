window.SockJS = require 'sockjs-client' # asteroid.cordova.js needs this
AsteroidClient = require 'asteroid/dist/asteroid.cordova.js'

class Asteroid
  constructor: (@Auth, @host) ->
    @_instance = new AsteroidClient(@host, true)

  login: ->
    @_instance.loginWithPassword "#{@Auth.user.id}", @Auth.user.authtoken

  subscribe: (name, params...) ->
    args = params
    args.unshift name
    @_instance.subscribe.apply null, args

  getCollection: (name) ->
    @_instance.getCollection name

module.exports = Asteroid
