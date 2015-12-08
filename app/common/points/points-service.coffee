class Points
  @$inject: ['$ionicPopup', 'Auth']
  constructor: (@$ionicPopup, @Auth) ->

  showPopup: ->
    imageUrl = @Auth.user.getImageUrl 100
    @$ionicPopup.show
      template: """
        <div class=\"points-popup\">
          <img class=\"points-img\" src=\"#{imageUrl}\">
          <h1 class=\"points-name\">#{@Auth.user.name}</h1>
          <h2 class=\"points-points\">#{@Auth.user.points} points</h2>
          <p class=\"points-explainer\">Tap <i class=\"calendar-star-selected points-calendar\"></i>'s or post fun things to do to earn points!</p>
        </div>
        """
      cssClass: 'popup-no-head'
      buttons: [
        text: 'OK'
      ]

module.exports = Points
