require '../common/resources/resources-module'
require '../common/auth/auth-module'
require '../common/local-db/local-db-module'
EventCtrl = require './event-controller'

angular.module 'rallytap.event', [
    'ionic'
    'rallytap.auth'
    'rallytap.resources'
    'rallytap.localDB'
    'ui.router'
  ]
  .config ($stateProvider) ->
    state = 
      url: '/event'
      templateUrl: 'app/event/event.html'
      controller: 'EventCtrl as event'
      params:
        ###
        savedEvent =
          id: 1
          ...
        ###
        savedEvent: null
        ###
        recommendedEvent =
          id: 1
          ...
        ###
        recommendedEvent: null
        commentsCount: null

    # Create states for each state that can 
    #   transition to the event view
    homeState = angular.extend {parent: 'home'}, state
    $stateProvider.state 'home.event', homeState

    friendChatState = angular.extend {parent: 'friendChat'}, state
    $stateProvider.state 'friendChat.event', friendChatState

    savedState = angular.extend {parent: 'saved'}, state
    $stateProvider.state 'saved.event', savedState
      
  .controller 'EventCtrl', EventCtrl
