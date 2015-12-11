require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require 'ng-cordova'
require '../ionic/ionic-angular.js'
require '../common/auth/auth-module'
require '../common/points/points-module'
require '../common/mixpanel/mixpanel-module'
FriendsCtrl = require './friends-controller'

describe 'add friends controller', ->
  $cordovaSocialSharing = null
  $ionicHistory = null
  $state = null
  $mixpanel = null
  $q = null
  $window = null
  Auth = null
  ctrl = null
  Points = null
  scope = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.points')

  beforeEach angular.mock.module('ngCordova')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach inject(($injector) ->
    $cordovaSocialSharing = $injector.get '$cordovaSocialSharing'
    $controller = $injector.get '$controller'
    $ionicHistory = $injector.get '$ionicHistory'
    $state = $injector.get '$state'
    $mixpanel = $injector.get '$mixpanel'
    $q = $injector.get '$q'
    $window = $injector.get '$window'
    Auth = $injector.get 'Auth'
    Points = $injector.get 'Points'
    scope = $injector.get '$rootScope'

    # Mock the current user.
    Auth.user = {id: 1}

    ctrl = $controller FriendsCtrl,
      $scope: scope
  )

  it 'should set the current user on the controller', ->
    expect(ctrl.currentUser).toBe Auth.user

  it 'should set the points service on the controller', ->
    expect(ctrl.Points).toBe Points


  ##showMyFriends
  describe 'tapping to view my friends', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.showMyFriends()

    it 'should go to the my friends view', ->
      expect($state.go).toHaveBeenCalledWith 'myFriends'


  ##showAddedMe
  describe 'tapping to view the people who added me', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.showAddedMe()

    it 'should go to the added me view', ->
      expect($state.go).toHaveBeenCalledWith 'addedMe'


  ##showAddFriends
  describe 'tapping to view the add friends view', ->

    beforeEach ->
      spyOn $state, 'go'

      ctrl.showAddFriends()

    it 'should go to the add friends view', ->
      expect($state.go).toHaveBeenCalledWith 'addFriends'

  ##hasSharePlugin
  describe 'checking if the social sharing plugin is installed', ->

    describe 'when installed', ->

      beforeEach ->
        $window.plugins =
          socialsharing: {}

      it 'should return true', ->
        expect(ctrl.hasSharePlugin()).toBe true


    describe 'when not installed', ->

      beforeEach ->
        $window.plugins =
          socialsharing: undefined

      it 'should return false', ->
        expect(ctrl.hasSharePlugin()).toBe false


  ##shareApp
  describe 'inviting friends to rallytap', ->
    deferred = null

    beforeEach ->
      spyOn $mixpanel, 'track'

      deferred = $q.defer()
      $cordovaSocialSharing.share = jasmine.createSpy('$cordovaSocialSharing.share') \
        .and.returnValue deferred.promise

      ctrl.shareApp()

    it 'should open the share dialog', ->
      inviteMessage = jasmine.any String
      inviteLink = jasmine.any String
      expect($cordovaSocialSharing.share).toHaveBeenCalledWith inviteMessage, inviteMessage, null, inviteLink

    describe 'when successful', ->

      beforeEach ->
        deferred.resolve()
        scope.$apply()

      it 'should track in mixpanel', ->
        expect($mixpanel.track).toHaveBeenCalledWith 'Share App'

