require 'angular-local-storage'
require 'angular-ui-router'
require '../common/auth/auth-module'
TutorialCtrl = require './tutorial-controller'

angular.module 'down.tutorial', [
    'down.auth'
    'LocalStorageModule'
    'ui.router'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'tutorial',
      url: '/tutorial'
      templateUrl: 'app/tutorial/tutorial.html'
      controller: 'TutorialCtrl as tutorial'
  .controller 'TutorialCtrl', TutorialCtrl
