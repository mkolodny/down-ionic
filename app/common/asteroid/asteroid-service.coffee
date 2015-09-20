window.SockJS = require 'sockjs-client' # asteroid.cordova.js needs this
AsteroidClient = require 'asteroid/dist/asteroid.cordova.js'

class Asteroid
  @$inject: ['Auth', 'meteorHost']
  constructor: (@Auth, @meteorHost) ->
    @_instance = new AsteroidClient(@meteorHost, true)

  login: ->
    @_instance.loginWithPassword "#{@Auth.user.id}", @Auth.user.authtoken

  subscribe: (name, params...) ->
    args = params
    args.unshift name
    @_instance.subscribe.apply @_instance, args

  getCollection: (name) ->
    @_instance.getCollection name

  call: (name, params...) ->
    args = params
    args.unshift name
    @_instance.call.apply @_instance, args

module.exports = Asteroid
