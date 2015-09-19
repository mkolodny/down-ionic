require '../../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-sanitize'
require 'angular-mocks'
require '../../ionic/ionic-angular.js'
require './view-place-module'

describe 'viewPlace directive', ->
  $ionicActionSheet = null
  $window = null
  checkAvailabilityCallback = null
  element = null
  scope = null
  span = null
  text = null

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.viewPlace')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $ionicActionSheet = $injector.get '$ionicActionSheet'
    $window = $injector.get '$window'
    scope = $injector.get '$rootScope'

    # Mock setting the place in the current scope.
    scope.place =
      name: 'Tiffin Wallah'
      lat: 40.7027217
      long: -73.9868878

    text = scope.place.name
    element = angular.element """
      <a href view-place place="place">#{text}</a>
      """
    $compile(element) scope
    scope.$digest()
    span = element.find 'span'
  )

  it 'should transclude it\'s contents', ->
    expect(span.html()).toBe "<span>#{text}</span>"

  describe 'tapping the view place link', ->
    actionSheetOptions = null

    beforeEach ->
      spyOn($ionicActionSheet, 'show').and.callFake (_options_) ->
        actionSheetOptions = _options_
      spyOn $window, 'open'

    describe 'on ios', ->

      beforeEach ->
        spyOn($window.ionic.Platform, 'isIOS').and.returnValue true

        $window.appAvailability =
          checkBool: jasmine.createSpy('appAvailability.checkBool').and.callFake \
              (_urlScheme_, _callback_) ->
            checkAvailabilityCallback = _callback_

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

          it 'should open the place in google maps', ->
            place = scope.place
            url = "comgooglemaps://?q=#{place.lat},#{place.long}&zoom=13"
            expect($window.open).toHaveBeenCalledWith url, '_system'


        describe 'tapping the second button', ->

          beforeEach ->
            actionSheetOptions.buttonClicked 1

          it 'should open the place in apple maps', ->
            place = scope.place
            url = "maps://?q=#{place.lat},#{place.long}"
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

          it 'should open the place in apple maps', ->
            place = scope.place
            url = "maps://?q=#{place.lat},#{place.long}"
            expect($window.open).toHaveBeenCalledWith url, '_system'


    describe 'on android', ->

      beforeEach ->
        spyOn($window.ionic.Platform, 'isIOS').and.returnValue false

        span.triggerHandler 'click'

      it 'should show an action sheet', ->
        expect($ionicActionSheet.show).toHaveBeenCalledWith
          buttons: [
            text: 'View in Maps'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function

      describe 'tapping the first button', ->

        beforeEach ->
          actionSheetOptions.buttonClicked 0

        it 'should open the place in google maps', ->
          place = scope.place
          url = "geo:0,0?q=#{place.lat},#{place.long}(#{place.name})"
          expect($window.open).toHaveBeenCalledWith url, '_system'
