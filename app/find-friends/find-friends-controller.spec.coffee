require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'angular-local-storage'
require '../common/auth/auth-module'
require '../common/contacts/contacts-module'
FindFriendsCtrl = require './find-friends-controller'

describe 'find friends controller', ->
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

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('down.contacts')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('LocalStorageModule')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    $state = $injector.get '$state'
    Auth = angular.copy $injector.get('Auth')
    Contacts = $injector.get 'Contacts'
    scope = $rootScope.$new true
    User = $injector.get 'User'
    localStorage = $injector.get 'localStorageService'

    deferred = $q.defer()
    spyOn(User, 'getFacebookFriends').and.returnValue {$promise: deferred.promise}

    contactsDeferred = $q.defer()
    spyOn(Contacts, 'getContacts').and.returnValue contactsDeferred.promise

    ctrl = $controller FindFriendsCtrl,
      Auth: Auth
      $scope: scope
      Contacts: Contacts
  )

  it 'should request the user\'s facebook friends', ->
    expect(User.getFacebookFriends).toHaveBeenCalled()

  it 'should request the user\'s contacts', ->
    expect(Contacts.getContacts).toHaveBeenCalled()

  describe 'when the facebook friends request returns', ->

    describe 'successfully', ->
      friend = null

      beforeEach ->
        friend = new User
          id: 1
          name: 'Alan Turing'
          username: 'tdog'
          imageUrl: 'https://graph.facebook.com/2.2/1598714293871/picture'
        deferred.resolve [friend]
        scope.$apply()

      it 'should set the friends on Auth', ->
        # TODO: Remove this.
        friends = {}
        friends[friend.id] = friend
        expect(Auth.friends).toEqual friends

      it 'should generate the items list', ->
        items = [
          isDivider: true
          title: 'Friends Using Down'
        ,
          isDivider: false
          id: friend.id
          name: friend.name
          username: friend.username
          imageUrl: friend.imageUrl
        ,
          isDivider: true
          title: 'Contacts'
        ]
        expect(ctrl.items).toEqual items


    describe 'with an error', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        expect(ctrl.fbFriendsRequestError).toBe true


  describe 'when the user finishes', ->

    beforeEach ->
      spyOn Auth, 'redirectForAuthState'
      localStorage.set 'hasCompletedFindFriends', false

      ctrl.done()

    afterEach ->
      localStorage.clearAll()

    it 'should set localStorage.hasCompletedFindFriends', ->
      expect(localStorage.get('hasCompletedFindFriends')).toBe true

    it 'should redirect for auth state', ->
      expect(Auth.redirectForAuthState).toHaveBeenCalled()

  describe 'when get contacts returns', ->

    describe 'successfully', ->

    describe 'with an error', ->

  describe 'sort items', ->

    describe 'item has a username', ->
      result = null
      item1 = null
      item2 = null

      beforeEach ->
        item1 =
          name: 'Jimbo Walker'
          username: 'j'
        item2 =
          name: 'Andrew Linfoot'
          username: 'a'

        result = ctrl.sortItems [item1, item2]

      it 'should be added to the Friends Using Down section', ->
        expect(result).toEqual [ [item2, item1], [] ]

    describe 'item has a phone', ->
      result = null
      item1 = null
      item2 = null

      beforeEach ->
        item1 =
          name: 'Mike Pleb'
          phone: '+19252852230'
        item2 =
          name: 'Linfoot Pleb'
          phone: '+15555555555'

        result = ctrl.sortItems [item1, item2]

      it 'should be added to the Contacts section', ->
        expect(result).toEqual [ [], [item2, item1] ]

  describe 'set items', ->
    sections = null
    result = null

    describe 'existing items', ->

      it 'should merge all items', ->

    describe 'no existing items', ->

      beforeEach ->
        sections = [
          ['someitem'],
          ['someotheritem']
        ]
        ctrl.items = [] # make sure items is empty
        result = ctrl.setItems sections

      it 'should add the friends using down and contacts dividers', ->
        divider1 =
          isDivider: true
          title: 'Friends Using Down'
        divider2 =
          isDivider: true
          title: 'Contacts'
        expect(result[0]).toEqual divider1
        expect(result[2]).toEqual divider2

      it 'should set the items', ->

