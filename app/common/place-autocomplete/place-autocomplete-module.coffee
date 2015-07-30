require 'angular'
placeAutocompleteDirective = require './place-autocomplete-directive'

angular.module 'down.placeAutocomplete', []
  .directive 'placeAutocomplete', placeAutocompleteDirective
