require 'angular'
require 'angular-mocks'
require 'angular-local-storage'
require 'ng-cordova'
RequestContactsCtrl = require './request-contacts-controller'

describe 'request contacts controller', ->
  $cordovaContacts = null
  $state = null
  $q = null
  Auth = null
  scope = null
  ctrl = null
  localStorage = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach angular.mock.module('ngCordova.plugins.contacts')

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $cordovaContacts = $injector.get '$cordovaContacts'
    $q = $injector.get '$q'
    localStorage = $injector.get 'localStorageService'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    scope = $rootScope.$new()
    Auth = angular.copy $injector.get('Auth')

    ctrl = $controller RequestContactsCtrl,
      $scope: scope
      Auth: Auth
  )

  afterEach ->
    localStorage.clearAll()

  describe 'request contacts permission', ->
    deferred = null

    beforeEach ->
      localStorage.set 'hasRequestedContacts', false

      deferred = $q.defer()
      spyOn($cordovaContacts, 'find').and.returnValue deferred.promise

      ctrl.requestContacts()

    it 'should find contacts contacts with phone numbers and names', ->
      fields = ['name', 'phoneNumbers']
      expect($cordovaContacts.find).toHaveBeenCalledWith fields

    it 'should set localStorage.hasRequestedContacts to true', ->
      expect(localStorage.get('hasRequestedContacts')).toBe true

    describe 'permission granted', ->
      contacts = null

      beforeEach ->
        spyOn ctrl, 'formatContacts'

        contacts = []
        deferred.resolve contacts
        scope.$apply()

      it 'should call format contacts', ->
        expect(ctrl.formatContacts).toHaveBeenCalledWith contacts

    describe 'an error occured', ->
      describe 'other errors', ->

        it 'should throw an error', ->

      describe 'permission denied', ->
        beforeEach ->
          spyOn Auth, 'redirectForAuthState'

          error = 
            code: 'ContactError.PERMISSION_DENIED_ERROR'

          deferred.reject error
          scope.$apply()

        it 'should redirect for auth state', ->
          expect(Auth.redirectForAuthState).toHaveBeenCalled()



    # it 'redirect for auth state', ->


# ContactError.PERMISSION_DENIED_ERROR