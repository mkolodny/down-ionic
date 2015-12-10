require 'angular-timeago'
require 'angular-ui-router'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
require '../common/mixpanel/mixpanel-module'
CommentsCtrl = require './comments-controller'

angular.module 'rallytap.comments', [
    'analytics.mixpanel'
    'angular-meteor'
    'rallytap.auth'
    'rallytap.resources'
    'ui.router'
    'yaru22.angular-timeago'
  ]
  .config ($stateProvider) ->
    state =
      url: '/comments/:id'
      templateUrl: 'app/comments/comments.html'
      controller: 'CommentsCtrl as comments'
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

    # Create states for each tab that can 
    #   transition to the comments view
    homeState = angular.extend {parent: 'home'}, state
    $stateProvider.state 'home.comments', homeState

    savedState = angular.extend {parent: 'saved'}, state
    $stateProvider.state 'saved.comments', savedState
      
  .controller 'CommentsCtrl', CommentsCtrl
