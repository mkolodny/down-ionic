require 'angular'
require 'angular-mocks'
require './place-autocomplete-module'

describe 'place-autocomplete', ->
  $compile = null
  scope = null
  newPlace = null
  place = null
  google = null
  modelName = null
  element = null

  beforeEach angular.mock.module('down.placeAutocomplete')

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    scope = $injector.get '$rootScope'
    newPlace = 'NYC'
    place =
      getPlace: jasmine.createSpy('getPlace').and.returnValue newPlace
    google = window.google =
      maps:
        places:
          Autocomplete: jasmine.createSpy('Autocomplete').and.returnValue place
        event:
          addListener: jasmine.createSpy 'addListener'
    modelName = 'modelName'

    element = angular.element "<input ng-model='#{modelName}' place-autocomplete>"
    $compile(element) scope
    scope.$digest()
  )

  it 'should create an Autocomplete object', ->
    expect(google.maps.places.Autocomplete).toHaveBeenCalledWith element[0],
      componentRestrictions: {country: 'us'}

  describe 'changing the place', ->
    location = null

    beforeEach ->
      spyOn scope, '$emit'

      # change the value of the input
      element.val newPlace

      # call the "place_changed" callback
      callback = google.maps.event.addListener.calls.first().args[2]
      callback()

    it 'should emit an event', ->
      expect(scope.$emit).toHaveBeenCalledWith 'placeAutocomplete:placeChanged',
          newPlace


  describe 'setting focus on the element', ->
    container = null

    beforeEach ->
      # Mock appending a google place container to the document body.
      container = angular.element '<div class="pac-container"></div>'
      angular.element(document.body).append container
      $compile(element) scope
      scope.$digest()

      element.triggerHandler 'focus'

    it 'should set a data-tap-disabled attribute', ->
      expect(container.attr('data-tap-disabled')).toBe 'true'

    it 'should set a pointer-events attribute', ->
      expect(container.css('pointer-events')).toBe 'auto'

    describe 'then clicking the container', ->

      beforeEach ->
        spyOn element[0], 'blur'

        container.triggerHandler 'click'

      it 'should blur the element', ->
        expect(element[0].blur).toHaveBeenCalled()
