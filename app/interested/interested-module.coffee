require 'angular-ui-router'
require 'ng-toast'
require '../common/resources/resources-module'
require '../common/auth/auth-module'
InterestedCtrl = require './interested-controller'

angular.module 'rallytap.interested', [
    'angular-meteor'
    'rallytap.auth'
    'rallytap.resources'
    'ui.router'
    'ngToast'
  ]
  .config ($stateProvider) ->
    state = 
      url: '/interested/:id'
      templateUrl: 'app/interested/interested.html'
      controller: 'InterestedCtrl as interested'
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

    # Create states for each state that can 
    #   transition to the interested view
    homeState = angular.extend {parent: 'home'}, state
    $stateProvider.state 'home.interested', homeState

    savedState = angular.extend {parent: 'saved'}, state
    $stateProvider.state 'saved.interested', savedState

  .controller 'InterestedCtrl', InterestedCtrl
