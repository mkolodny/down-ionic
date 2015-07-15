require 'angular-mocks'
require './auth-module'

describe 'Auth service', ->
  Auth = null

  beforeEach angular.mock.module('down.auth')

  beforeEach inject((_Auth_) ->
    Auth = _Auth_
  )

  it 'should init the user', ->
    expect(Auth.user).toEqual {}
