class TutorialCtrl
  @$inject: ['$scope', 'Auth', 'localStorageService']
  constructor: (@$scope, @Auth, localStorageService) ->
    @localStorage = localStorageService

    # Init the view.
    @currentSection = 0

    @$scope.$on '$ionicView.beforeEnter', =>
      @isAuthenticated = angular.isDefined @Auth.user.id

  isCurrentSection: (index) ->
    @currentSection is index

  setSection: (index) ->
    @currentSection = index

  continue: ->
    @localStorage.set 'hasViewedTutorial', true
    @Auth.redirectForAuthState()

module.exports = TutorialCtrl
