require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
TeamCtrl = require './team-controller'

describe 'team controller', ->
  $meteor = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $meteor = $injector.get '$meteor'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'

    ctrl = $controller TeamCtrl,
      $scope: scope
  )

  ##login
  describe 'logging in', ->
    deferredGetTeam = null

    beforeEach ->
      deferredGetTeam = $q.defer()
      spyOn(Auth, 'getTeamRallytap').and.returnValue
        $promise: deferredGetTeam.promise

      ctrl.login()

    it 'should get the rallytap user', ->
      expect(Auth.getTeamRallytap).toHaveBeenCalled()

    describe 'successfully', ->
      deferredMeteorLogin = null
      teamrallytap = null

      beforeEach ->
        deferredMeteorLogin = $q.defer()
        $meteor.loginWithPassword.and.returnValue deferredMeteorLogin.promise

        teamrallytap =
          id: 1
          authtoken: 'a'
        deferredGetTeam.resolve teamrallytap
        scope.$apply()

      it 'should attempt to login', ->
        expect($meteor.loginWithPassword).toHaveBeenCalledWith("#{teamrallytap.id}",
            teamrallytap.authtoken)

      describe 'successfully', ->

        beforeEach ->
          spyOn Auth, 'setUser'
          spyOn $state, 'go'

          deferredMeteorLogin.resolve()
          scope.$apply()

        it 'should set the current user', ->
          expect(Auth.setUser).toHaveBeenCalledWith teamrallytap

        it 'should go to the events view', ->
          expect($state.go).toHaveBeenCalledWith 'events'


      describe 'unsuccessfully', ->

        beforeEach ->
          deferredMeteorLogin.reject()
          scope.$apply()

        it 'should show an error', ->
          expect(ctrl.error).toBe 'Son of a.... That didn\'t work.'


    describe 'unsuccessfully', ->

      beforeEach ->
        deferredGetTeam.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.error).toBe 'Son of a.... That didn\'t work.'

      describe 'trying again', ->

        beforeEach ->
          ctrl.login()

        it 'should clear the error', ->
          expect(ctrl.error).toBeNull()
