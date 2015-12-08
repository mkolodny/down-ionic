require '../../ionic/ionic.js'
require 'angular'
require 'angular-mocks'
require './points-module'

describe 'Points service', ->
  $ionicPopup = null
  Auth = null
  Points = null
  User = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('rallytap.points')

  beforeEach inject(($injector) ->
    $ionicPopup = $injector.get '$ionicPopup'
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

  ##showPopup
  describe 'showing the points explainer popup', ->

    beforeEach ->
      spyOn $ionicPopup, 'show'

      Points.showPopup()

    it 'should show an ionic popup', ->
      imageUrl = Auth.user.getImageUrl 100
      expect($ionicPopup.show).toHaveBeenCalledWith
        template: """
          <div class=\"points-popup\">
            <img class=\"points-img\" src=\"#{imageUrl}\">
            <h1 class=\"points-name\">#{Auth.user.name}</h1>
            <h2 class=\"points-points\">#{Auth.user.points} points</h2>
            <p class=\"points-explainer\">Tap <i class=\"calendar-star-selected points-calendar\"></i>'s or post fun things to do to earn points!</p>
          </div>
          """
        cssClass: 'popup-no-head'
        buttons: [
          text: 'OK'
        ]
