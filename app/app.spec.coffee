window.jQuery = require 'jquery' # required for intl phone
require 'angular'

beforeEach ->
  jasmine.addMatchers
    toAngularEqual: ->
      compare: (actual, expected) ->
        pass: angular.equals(actual, expected)

    toHaveClass: ->
      compare: (actual, expected) =>
        pass: actual.hasClass expected
