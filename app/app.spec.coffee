window.jQuery = require 'jquery' # required for intl phone
require 'angular'

beforeEach ->
  customMatchers =
    toAngularEqual: ->
      compare: (actual, expected) ->
        return pass: angular.equals(actual, expected)

  jasmine.addMatchers customMatchers
