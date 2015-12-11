require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../common/auth/auth-module'
require '../common/resources/resources-module'
require '../common/local-db/local-db-module'
EventCtrl = require './event-controller'

describe 'event controller', ->
  $ionicModal = null
  $rootScope = null
  $q = null
  Auth = null
  commentsCount = null
  ctrl = null
  Friendship = null
  LocalDB = null
  savedEvent = null
  scope = null
  recommendedEvent = null

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.localDB')

  beforeEach angular.mock.module('ionic')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $stateParams = angular.copy $injector.get('$stateParams')
    $rootScope = $injector.get '$rootScope'
    $ionicModal = $injector.get '$ionicModal'
    $q = $injector.get '$q'
    Auth = $injector.get 'Auth'
    Friendship = $injector.get 'Friendship'
    LocalDB = $injector.get 'LocalDB'
    scope = $rootScope

    savedEvent =
      id: 1
      eventId: 2
      event:
        id: 2
    commentsCount = 16
    recommendedEvent =
      id: 1
    $stateParams.savedEvent = savedEvent
    $stateParams.commentsCount = commentsCount
    $stateParams.recommendedEvent = recommendedEvent

    ctrl = $controller EventCtrl,
      $stateParams: $stateParams
      $scope: scope
  )

  it 'should set the saved event on the controller', ->
    expect(ctrl.savedEvent).toBe savedEvent

  it 'should set the comments count on the controller', ->
    expect(ctrl.commentsCount).toBe commentsCount

  it 'should set the recommended event on the controller', ->
    expect(ctrl.recommendedEvent).toBe recommendedEvent

  it 'shoud init the contacts object on the controller', ->
    expect(ctrl.contacts).toEqual {}

  ##$ionicView.load
  describe 'the first time the view loads', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(LocalDB, 'get').and.returnValue deferred.promise
      spyOn ctrl, 'setupSearchModal'

      scope.$broadcast '$ionicView.loaded'
      scope.$apply()

    it 'should setup the search modal', ->
      expect(ctrl.setupSearchModal).toHaveBeenCalled()

    it 'should get the contacts', ->
      expect(LocalDB.get).toHaveBeenCalledWith 'contacts'

    describe 'when the contacts are returned successfully', ->
      contacts = null

      beforeEach ->
        contacts = {}
        deferred.resolve contacts
        scope.$apply()

      it 'should set the contacts on the controller', ->
        expect(ctrl.contacts).toEqual contacts


  ##$ionicView.beforeEnter
  describe 'when the view enters', ->
    items = null

    beforeEach ->
      items = []
      spyOn(ctrl, 'buildItems').and.returnValue items

      $rootScope.$broadcast '$ionicView.beforeEnter'
      $rootScope.$apply()

    it 'should hide the tab bar', ->
      expect($rootScope.hideTabBar).toBe true

    it 'should set the items on the controller', ->
      expect(ctrl.items).toBe items


  ##setupSearchModal
  describe 'setting up the search modal', ->
    modal = null


    beforeEach ->
      spyOn($ionicModal, 'fromTemplate').and.returnValue modal

      ctrl.setupSearchModal()
    
    it 'should init the search modal', ->
      expect($ionicModal.fromTemplate).toHaveBeenCalledWith jasmine.any(String),
        scope: scope
        animation: 'slide-in-up'
        focusFirstInput: true
    
    it 'should set the modal on the controller', ->
      expect(ctrl.searchModal).toBe modal

    describe 'cleaning up the search modal', ->

      beforeEach ->
        ctrl.searchModal =
          remove: jasmine.createSpy 'searchModal.remove'
        scope.$broadcast '$destroy'
        scope.$apply()

      it 'should remove the search modal', ->
        expect(ctrl.searchModal.remove).toHaveBeenCalled()


  ##hideSearchModal
  describe 'hiding the search modal', ->

    beforeEach ->
      ctrl.searchModal =
        hide: jasmine.createSpy 'searchModal.hide'
      ctrl.hideSearchModal()

    it 'should hide the search modal', ->
      expect(ctrl.searchModal.hide).toHaveBeenCalled()


  ##buildItems
  describe 'building the items', ->
    items = null

    beforeEach ->
      # Mock the logged in user.
      Auth.user =
        id: 1
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pics/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535

      # Mock the user's friends.
      Auth.user.friends =
        2:
          id: 2
          email: 'ltorvalds@gmail.com'
          name: 'Linus Torvalds'
          username: 'valding'
          imageUrl: 'https://facebook.com/profile-pics/valding'
          location:
            lat: 40.7265834 # just under 5 mi away
            long: -73.9821535
        3:
          id: 3
          email: 'jclarke@gmail.com'
          name: 'Joan Clarke'
          username: 'jnasty'
          imageUrl: 'https://facebook.com/profile-pics/jnasty'
          location:
            lat: 40.7265834 # under 5 mi away, farther than user 2
            long: -73.9821535
        4:
          id: 4
          email: 'gvrossum@gmail.com'
          name: 'Guido van Rossum'
          username: 'vrawesome'
          imageUrl: 'https://facebook.com/profile-pics/vrawesome'
          location:
            lat: 40.79893 # just over 5 mi away
            long: -73.9821535
        5:
          id: 5
          name: '+19252852230'
      Auth.user.facebookFriends =
        4: Auth.user.friends[4]
        6:
          id: 6
          email: 'jimjohn@gmail.com'
          name: 'Jim John'
          username: 'jimjohn'
          imageUrl: 'https://facebook.com/profile-pics/jimjohn'
          location:
            lat: 40.79893 # just over 5 mi away
            long: -73.9821535
      ctrl.contacts =
        4: Auth.user.friends[4]
        7:
          id: 7
          email: 'thesexiestmanalive@gmail.com'
          name: 'Andrew Linfoot'
          username: 'toobeautiful'
          imageUrl: 'https://facebook.com/profile-pics/soosooogoodlooking'
          location:
            lat: 40.79893 # just over 5 mi away
            long: -73.9821535

      items = ctrl.buildItems()

    it 'should build the items', ->
      # Items order
      #   friends
      #   facebook friends, no duplicates
      #   contacts, no duplicates
      expectedItems = [
        user: Auth.user.friends[2]
      ,
        user: Auth.user.friends[3]
      ,
        user: Auth.user.friends[4]
      ,
        user: Auth.user.friends[5]
      ,
        user: Auth.user.facebookFriends[6]
      ,
        user: ctrl.contacts[7]
      ]
      expect(items).toEqual expectedItems


  ##showSearchModal
  describe 'showing the search modal', ->

    beforeEach ->
      ctrl.searchModal =
        show: jasmine.createSpy 'searchModal.show'
      ctrl.showSearchModal()

    it 'should show the modal', ->
      expect(ctrl.searchModal.show).toHaveBeenCalled()