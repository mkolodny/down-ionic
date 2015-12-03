require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require '../ionic/ionic-angular.js'
require '../common/auth/auth-module'
FriendsCtrl = require './friends-controller'

describe 'add friends controller', ->
  $ionicHistory = null
  $state = null
  Auth = null
  ctrl = null
  scope = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicHistory = $injector.get '$ionicHistory'
    $state = $injector.get '$state'
    Auth = $injector.get 'Auth'
    scope = $injector.get '$rootScope'

    # Mock the current user.
    Auth.user = {id: 1}

    ctrl = $controller FriendsCtrl,
      $scope: scope
  )

  it 'should set the current user on the controller', ->
    expect(ctrl.currentUser).toBe Auth.user

  describe 'tapping to add by username', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addByUsername()

    it 'should go to the add by username view', ->
      expect($state.go).toHaveBeenCalledWith 'addByUsername'


  describe 'tapping to add by phone', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addByPhone()

    it 'should go to the add by phone view', ->
      expect($state.go).toHaveBeenCalledWith 'addByPhone'


  describe 'tapping to add from address book', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromAddressBook()

    it 'should go to the add from address book view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromAddressBook'


  describe 'tapping to add from facebook', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.addFromFacebook()

    it 'should go to the add from facebook view', ->
      expect($state.go).toHaveBeenCalledWith 'addFromFacebook'


  describe 'tapping to view my friends', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.showMyFriends()

    it 'should go to the my friends view', ->
      expect($state.go).toHaveBeenCalledWith 'myFriends'


  describe 'tapping to view the people who added me', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.showAddedMe()

    it 'should go to the added me view', ->
      expect($state.go).toHaveBeenCalledWith 'addedMe'

