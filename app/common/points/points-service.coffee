class Points
  @$inject: ['$ionicPopup', '$rootScope', 'Auth']
  constructor: (@$ionicPopup, @$rootScope, @Auth) ->
    @$rootScope.close = @hidePopup

  showPopup: ->
    imageUrl = @Auth.user.getImageUrl 100
    @popup = @$ionicPopup.show
      template: """
        <div class=\"points-popup\">
          <i class="fa fa-close points-close" ng-click="close()"></i>
          <img class=\"points-img\" src=\"#{imageUrl}\">
          <h1 class=\"points-name\">#{@Auth.user.name}</h1>
          <h2 class=\"points-points\">#{@Auth.user.points} points</h2>
          <p class=\"points-explainer\">Tap <i class=\"calendar-star-selected points-calendar\"></i>'s or post fun things to do to earn points!</p>
        </div>
        """
      cssClass: 'popup-no-head'
      scope: @$rootScope

  hidePopup: =>
    @popup.close()

module.exports = Points
