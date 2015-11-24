require 'angular-ui-router'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
EventCtrl = require './event-controller'

angular.module 'rallytap.event', [
    'angular-meteor'
    'rallytap.auth'
    'rallytap.resources'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'home.event',
      url: '/event/:id'
      templateUrl: 'app/event/event.html'
      controller: 'EventCtrl as event'
      params:
        ###
        event =
          id: 1
          title: Beers?!?
          datetime: new Date()
          place:
            name: 'B Bar & Grill'
            lat: 40.7270718
            long: -73.9919324
          createdAt: new Date()
        ###
        event: null
  .controller 'EventCtrl', EventCtrl
