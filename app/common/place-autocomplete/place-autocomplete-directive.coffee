placeAutocompleteDirective = ->
  require: 'ngModel'
  link: (scope, element, attrs, model) ->
    # TODO: Get the options from an element attribute to make this more generic.
    options =
      componentRestrictions:
        country: 'us'
    place = new google.maps.places.Autocomplete(element[0], options)

    google.maps.event.addListener place, 'place_changed', ->
      model.$setViewValue element.val() # TODO: Test this.
      scope.$emit 'placeAutocomplete:placeChanged', place.getPlace()

    element.on 'focus', =>
      container = document.getElementsByClassName 'pac-container'
      angular.element container
        .attr 'data-tap-disabled', 'true'
        .css 'pointer-events', 'auto'
        .on 'click', =>
          element[0].blur()
      return

module.exports = placeAutocompleteDirective

# TODO: Publish this!!!

# Answer these questions:
# http://stackoverflow.com/questions/30333466/cannot-select-from-google-places-autocomplete
# See the discussion here: https://github.com/driftyco/ionic/issues/1798
