require 'angular'

beforeEach ->
  jasmine.DEFAULT_UPDATE_INTERVAL = 0

  jasmine.addMatchers
    toAngularEqual: ->
      compare: (actual, expected) ->
        pass: angular.equals(actual, expected)

    toHaveClass: ->
      compare: (actual, expected) =>
        pass: actual.hasClass expected
