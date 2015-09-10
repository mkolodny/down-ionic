require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require 'angular-local-storage'
require '../ionic/ionic-angular.js'
require '../common/auth/auth-module'
require '../common/contacts/contacts-module'
FindFriendsCtrl = require './find-friends-controller'

describe 'find friends controller', ->
  $controller = null
  $ionicLoading = null
  $q = null
  $state = null
  Auth = null
  ctrl = null
  deferred = null
  contactsDeferred = null
  scope = null
  Contacts = null
  User = null
  localStorage = null
  facebookFriend = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.contacts')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicLoading = $injector.get '$ionicLoading'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    Contacts = $injector.get 'Contacts'
    scope = $rootScope
    User = $injector.get 'User'
    localStorage = $injector.get 'localStorageService'

    contactsDeferred = $q.defer()
    spyOn(Contacts, 'getContacts').and.returnValue contactsDeferred.promise

    # Need dis in the constructor
    facebookFriend =
      id: '1234'
      name: 'Chris MacPleb'
      username: 'm'
      imageUrl: 'thatImage.com'
    Auth.user.facebookFriends = {}
    Auth.user.facebookFriends[facebookFriend.id] = facebookFriend

    ctrl = $controller FindFriendsCtrl,
      $scope: scope
      Auth: Auth
  )

  afterEach ->
    localStorage.clearAll()

  it 'should set isLoading to true', ->
    expect(ctrl.isLoading).toEqual true

  describe 'when the view finishes loading', ->

    beforeEach ->
      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'

      scope.$emit '$ionicView.enter'

    it 'should show a loading overlay', ->
      template = '''
        <div class="loading-text" id="loading-contacts">Loading your contacts...<br>(This might take a while)</div>
        <ion-spinner icon="bubbles"></ion-spinner>
        '''
      expect($ionicLoading.show).toHaveBeenCalledWith template: template

    it 'should request the user\'s contacts', ->
      expect(Contacts.getContacts).toHaveBeenCalled()

    describe 'when get contacts returns', ->

      describe 'successfully', ->
        contacts = null
        items = null

        beforeEach ->
          contact =
            id: 1234
            name: 'Mike Pleb'
            phoneNumbers: [
              value: '+1952852230'
            ]
          items = [
            isDivider: true
            title: 'Friends Using Down'
          ,
            isDivider: false
            user: facebookFriend
          ,
            isDivider: true
            title: 'Contacts'
          ,
            isDivider: false
            contact: contact
          ]
          spyOn(ctrl, 'buildItems').and.returnValue items

          contacts =
            1234: contact
          contactsDeferred.resolve contacts
          scope.$apply()

        it 'should build the items list', ->
          expect(ctrl.buildItems).toHaveBeenCalledWith Auth.user.facebookFriends,
              contacts

        it 'should set the items on the controller', ->
          expect(ctrl.items).toBe items

        it 'should stop the loading indicator', ->
          expect(ctrl.isLoading).toBe false

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


      describe 'with an error', ->
        beforeEach ->
          contactsDeferred.reject()
          scope.$apply()

        it 'should set isLoading to false', ->
          expect(ctrl.isLoading).toEqual false

        it 'should show an error', ->
          expect(ctrl.contactsRequestError).toBe true

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


  describe 'when the user has facebook friends', ->

    it 'should create and set items for facebook friends', ->
      items = [
        isDivider: true
        title: 'Friends Using Down'
      ,
        isDivider: false
        user:
          id: facebookFriend.id
          name: facebookFriend.name
          username: facebookFriend.username
          imageUrl: facebookFriend.imageUrl
      ]
      expect(ctrl.items).toEqual items


  describe 'building the items list', ->
    contactWithoutUser = null
    contactWithFbFriend = null
    contactWithUser = null
    result = null

    beforeEach ->
      contactWithoutUser =
        id: 1
        name:
          formatted: 'Mike Pleb'
        phoneNumbers: [
          value: '+1952852230'
        ]
      contactWithUser =
        id: 2
        name:
          formatted: 'Andrew Plebfoot'
        phoneNumbers: [
          value: '+1952852231'
        ]
        user:
          id: 3
          name: 'Andrew Plebfoot'
          username: 'a'
      contactWithFbFriend =
        id: 3
        name:
          formatted: 'Chris MacPleb'
        phoneNumbers: [
          value: '+1952852231'
        ]
        user:
          id: facebookFriend.id
          name: 'Chris MacPleb'
          username: 'cmac9889'
      contacts = [
        contactWithoutUser
        contactWithUser
        contactWithFbFriend
      ]
      contactsDict = {}
      for contact in contacts
        contactsDict[contact.id] = contact

      result = ctrl.buildItems Auth.user.facebookFriends, contactsDict

    it 'should return the built items', ->
      items = [
        isDivider: true
        title: 'Friends Using Down'
      ,
        isDivider: false
        user: contactWithUser.user
      ,
        isDivider: false
        user: facebookFriend
      ,
        isDivider: true
        title: 'Contacts'
      ,
        isDivider: false
        contact: contactWithoutUser
      ]
      expect(result).toEqual items


  describe 'when the user finishes', ->

    beforeEach ->
      spyOn Auth, 'redirectForAuthState'
      localStorage.set 'hasCompletedFindFriends', false

      ctrl.done()

    afterEach ->
      localStorage.clearAll()

    it 'should set localStorage.hasCompletedFindFriends', ->
      expect(localStorage.get 'hasCompletedFindFriends').toBe true

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()


  describe 'getting a contact\'s initials', ->

    describe 'when they have multiple words in their name', ->

      it 'should return the first letter of their first and last name', ->
        expect(ctrl.getInitials 'Alan Tdog Turing').toBe 'AT'


    describe 'when they have one word in their name', ->

      it 'should return the first two letters of their name', ->
        expect(ctrl.getInitials 'Pele').toBe 'PE'


    describe 'when they have one letter in their name', ->

      it 'should return the first letter of their name', ->
        expect(ctrl.getInitials 'p').toBe 'P'


    describe 'when they have no last name', ->

      describe 'and multiple letters in their first name', ->

        it 'should return the first two letters of their first name', ->
          expect(ctrl.getInitials 'Pele ').toBe 'PE'


      describe 'and one letter in their first name', ->

        it 'should return the first two letters of their first name', ->
          expect(ctrl.getInitials 'P ').toBe 'P'
