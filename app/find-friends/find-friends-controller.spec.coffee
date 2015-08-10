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
  facebookFriend = null

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

    # Need dis in the constructor
    facebookFriend =
      id: '1234'
      name: 'Mike Pleb'
      username: 'm'
      imageUrl: 'thatImage.com'
    Auth.user.facebookFriends = [facebookFriend]

    ctrl = $controller FindFriendsCtrl,
      Auth: Auth
      $scope: scope
      Contacts: Contacts
  )

  it 'should init a blank items array', ->
    expect(ctrl.items).toEqual []

  it 'should request the user\'s contacts', ->
    expect(Contacts.getContacts).toHaveBeenCalled()

  describe 'when the user has facebook friends', ->

    it 'should create and set items for facebook friends', ->
      items = [
        isDivider: true
        title: 'Friends Using Down'
      ,
        isDivider: false
        id: facebookFriend.id
        name: facebookFriend.name
        username: facebookFriend.username
        imageUrl: facebookFriend.imageUrl
      ,
        isDivider: true
        title: 'Contacts'
      ]

      expect(ctrl.items).toEqual items

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
      items = null
      contactsObject = null

      beforeEach ->
        name = 'Mike Pleb'
        phone = '+1952852230'
        contact =
          id: 1234
          name: 
            formatted: name,
          phoneNumbers: [ {value: phone} ]
        contactsObject =
          1234: contact
        items = [
          isDivider: false
          name: name
          contact: contact
        ]
        spyOn(ctrl, 'contactsToItems').and.returnValue items
        spyOn(ctrl, 'mergeItems').and.returnValue items
        spyOn(ctrl, 'sortItems').and.returnValue items
        spyOn ctrl, 'setItems'

        contactsDeferred.resolve contactsObject
        scope.$apply()

      it 'should call contactsToItems with contacts', ->
        expect(ctrl.contactsToItems).toHaveBeenCalledWith contactsObject

      it 'should merge the items', ->
        expect(ctrl.mergeItems).toHaveBeenCalledWith items

      it 'should sort the items', ->
        expect(ctrl.sortItems).toHaveBeenCalledWith items

      it 'should set the items', ->
        expect(ctrl.setItems).toHaveBeenCalledWith items

    describe 'with an error', ->
      beforeEach ->
        contactsDeferred.reject()
        scope.$apply()

      fit 'should show an error', ->
        expect(ctrl.contactsRequestError).toBe true

  describe 'contacts to items', ->
    contact = null
    contactsObject = null
    items = null
    item = null

    describe 'when a contact has a user id', ->

      beforeEach ->
        name = 'Andrew Plebfoot'
        username = 'a'
        userId = 1
        imageUrl = 'thatImage.com'

        contact =
          id: '1234'
          name:
            formatted: name
          phoneNumbers: [ {value: '+19252852230'} ]
          user:
            id: userId
            username: username
            imageUrl: imageUrl
        contactsObject =
          1234: contact
        item =
          name: name
          isDivider: false
          contact: contact
          username: username
          imageUrl: imageUrl
          id: userId

        items = ctrl.contactsToItems contactsObject

      it 'should format the contacts to the item format', ->
        expect(items).toEqual [item]

    describe 'when a contact doesn\'t have a user id', ->

      beforeEach ->
        name = 'Andrew Plebfoot'
        contact = 
          id: '1234'
          name:
            formatted: name,
          phoneNumbers: [ {value: '+1925282230'} ]
        contactsObject =
          1234: contact
        item =
          name: name
          isDivider: false
          contact: contact
        items = ctrl.contactsToItems contactsObject

      it 'should format the contacts to the item format', ->
        expect(items).toEqual [item]
      
  describe 'merge items', ->
    newItems = null
    mergedItems = null

    beforeEach ->
      newItems = [
        isDivider: false
      ,
        isDivider: false
      ]

    describe 'when there are existing items', ->
      beforeEach ->
        ctrl.items = [
          isDivider: true
          title: 'Friends Using Down'
        ,
          isDivider: false
        ]
        mergedItems = ctrl.mergeItems newItems
      
      it 'should remove dividers', ->
        for item in mergedItems
          expect(item.isDivider).toEqual false

      it 'should combine the new and old items', ->
        expect(mergedItems.length).toEqual 3

    describe 'when there are not existing items', ->
      beforeEach ->
        ctrl.items = []
        mergedItems = ctrl.mergeItems newItems

      it 'should return the new items', ->
        expect(mergedItems).toEqual newItems

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

    beforeEach ->
      sections = [
        ['someitem'],
        ['someotheritem']
      ]
      ctrl.items = [] # make sure items is empty
      ctrl.setItems sections

    it 'should add the friends using down and contacts dividers', ->
      divider1 =
        isDivider: true
        title: 'Friends Using Down'
      divider2 =
        isDivider: true
        title: 'Contacts'
      expect(ctrl.items[0]).toEqual divider1
      expect(ctrl.items[2]).toEqual divider2

    it 'should set the items', ->

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

