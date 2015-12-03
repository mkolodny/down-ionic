require 'angular-ui-router'
require 'angular-timeago'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
CommentsCtrl = require './comments-controller'

angular.module 'rallytap.comments', [
    'angular-meteor'
    'rallytap.auth'
    'rallytap.resources'
    'ui.router'
    'yaru22.angular-timeago'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'comments',
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
  .controller 'CommentsCtrl', CommentsCtrl
