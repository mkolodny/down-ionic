require '../../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-sanitize'
require 'angular-mocks'
require '../../ionic/ionic-angular.js'
require './view-location-module'

describe 'viewLocation directive', ->
  $ionicActionSheet = null
  $window = null
  checkAvailabilityCallback = null
  element = null
  scope = null
  span = null
  text = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.viewLocation')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $ionicActionSheet = $injector.get '$ionicActionSheet'
    $window = $injector.get '$window'
    scope = $injector.get '$rootScope'

    # Mock setting the location in the current scope.
    scope.location =
      lat: 40.7027217
      long: -73.9868878

    text = 'View Location'
    element = angular.element """
      <a href view-location location="location">#{text}</a>
      """
    $compile(element) scope
    scope.$digest()
    span = element.find 'span'
  )

  it 'should transclude it\'s contents', ->
    expect(span.html()).toBe "<span>#{text}</span>"

  describe 'tapping the view location link', ->
    urlScheme = null
    actionSheetOptions = null

    beforeEach ->
      $window.appAvailability =
        checkBool: jasmine.createSpy('appAvailability.checkBool').and.callFake \
            (_urlScheme_, _callback_) ->
          urlScheme = _urlScheme_
          checkAvailabilityCallback = _callback_
      spyOn($ionicActionSheet, 'show').and.callFake (_options_) ->
        actionSheetOptions = _options_
      spyOn $window, 'open'

      span.triggerHandler 'click'

    it 'should check whether google maps is available', ->
      expect($window.appAvailability.checkBool).toHaveBeenCalledWith \
          'comgooglemaps://', jasmine.any(Function)

    describe 'when google maps is available', ->

      beforeEach ->
        checkAvailabilityCallback true

      it 'should show an action sheet with google maps as an option', ->
        expect($ionicActionSheet.show).toHaveBeenCalledWith
          buttons: [
            text: 'View in Google Maps'
          ,
            text: 'View in Maps'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function

      describe 'tapping the first button', ->

        beforeEach ->
          actionSheetOptions.buttonClicked 0

        it 'should open the location in google maps', ->
          location = scope.location
          url = "comgooglemaps://?q=#{location.lat},#{location.long}&zoom=13"
          expect($window.open).toHaveBeenCalledWith url, '_system'


      describe 'tapping the second button', ->

        beforeEach ->
          actionSheetOptions.buttonClicked 1

        it 'should open the location in apple maps', ->
          location = scope.location
          url = "maps://?q=#{location.lat},#{location.long}"
          expect($window.open).toHaveBeenCalledWith url, '_system'


    describe 'when google maps isn\'t available', ->

      beforeEach ->
        checkAvailabilityCallback false

      it 'should show an action sheet with only maps as an option', ->
        expect($ionicActionSheet.show).toHaveBeenCalledWith
          buttons: [
            text: 'View in Maps'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function

      describe 'tapping the first button', ->

        beforeEach ->
          actionSheetOptions.buttonClicked 0

        it 'should open the location in apple maps', ->
          location = scope.location
          url = "maps://?q=#{location.lat},#{location.long}"
          expect($window.open).toHaveBeenCalledWith url, '_system'
