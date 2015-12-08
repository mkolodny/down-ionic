require '../../ionic/ionic.js'
require 'angular'
require 'angular-mocks'
require './points-module'

describe 'Points service', ->
  $ionicPopup = null
  $rootScope = null
  Auth = null
  Points = null
  User = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('rallytap.points')

  beforeEach inject(($injector) ->
    $ionicPopup = $injector.get '$ionicPopup'
    $rootScope = $injector.get '$rootScope'
    Auth = $injector.get 'Auth'
    Points = $injector.get 'Points'
    User = $injector.get 'User'

    # Mock the current user.
    Auth.user = new User
      id: 1
      name: 'Javon Kearse'
      points: 216
      imageUrl: 'http://imgur.com/baller'
  )

  it 'should set the hidePopup function on the controller', ->
    expect($rootScope.close).toBe Points.hidePopup

  ##showPopup
  describe 'showing the points explainer popup', ->
    popup = null

    beforeEach ->
      spyOn($ionicPopup, 'show').and.callFake (options) ->
        popup = 'popup'
        popup

      Points.showPopup()

    it 'should show an ionic popup', ->
      imageUrl = Auth.user.getImageUrl 100
      expect($ionicPopup.show).toHaveBeenCalledWith
        template: """
          <div class=\"points-popup\">
            <i class="fa fa-close points-close" ng-click="close()"></i>
            <img class=\"points-img\" src=\"#{imageUrl}\">
            <h1 class=\"points-name\">#{Auth.user.name}</h1>
            <h2 class=\"points-points\">#{Auth.user.points} points</h2>
            <p class=\"points-explainer\">Tap <i class=\"calendar-star-selected points-calendar\"></i>'s or post fun things to do to earn points!</p>
          </div>
          """
        cssClass: 'popup-no-head'
        scope: $rootScope

    it 'should set the popup on the service', ->
      expect(Points.popup).toBe popup


  ##hidePopup
  describe 'hiding the points popup', ->

    beforeEach ->
      Points.popup =
        close: jasmine.createSpy 'Points.popup.close'

      Points.hidePopup()

    it 'should close the popup', ->
      expect(Points.popup.close).toHaveBeenCalled()
