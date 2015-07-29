placeAutocompleteDirective = ->
  require: 'ngModel'
  link: (scope, element, attrs, model) ->
    options =
      componentRestrictions:
        country: 'us'
    place = new google.maps.places.Autocomplete element[0], options

    google.maps.event.addListener place, 'place_changed', ->
      model.$setViewValue element.val()
      scope.$emit 'placeAutocomplete:placeChanged', place.getPlace()

module.exports = placeAutocompleteDirective
