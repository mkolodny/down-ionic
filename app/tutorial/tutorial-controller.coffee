class TutorialCtrl
  @$inject: ['$scope', 'Auth']
  constructor: (@$scope, @Auth) ->
    # Init the view.
    @currentSection = 0

    @$scope.$on '$ionicView.beforeEnter', =>
      @isAuthenticated = angular.isDefined @Auth.user.id

  isCurrentSection: (index) ->
    @currentSection is index

  setSection: (index) ->
    @currentSection = index

  continue: ->
    @Auth.setFlag 'hasViewedTutorial', true
    @Auth.redirectForAuthState()

module.exports = TutorialCtrl
