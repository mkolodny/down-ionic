EventCtrl = require './event-controller'

angular.module 'rallytap.event', [
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'event',
      url: '/event'
      parent: 'home'
      templateUrl: 'app/event/event.html'
      controller: 'EventCtrl as event'
      params:
        ###
        savedEvent =
          id: 1
          ...
        ###
        savedEvent: null
        commentsCount: null
  .controller 'EventCtrl', EventCtrl
