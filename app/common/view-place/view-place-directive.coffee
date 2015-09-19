viewPlaceDirective = ['$ionicActionSheet', '$window', ($ionicActionSheet, $window) ->
  restrict: 'A'
  scope:
    place: '='
  template: '<span ng-click="showActionSheet()" ng-transclude></span>'
  transclude: true
  controller: ['$scope', ($scope) ->
    $scope.showActionSheet = ->
      if $window.ionic.Platform.isIOS()
        $window.appAvailability.checkBool 'comgooglemaps://', \
            (isGoogleMapsAvailable) ->
          if isGoogleMapsAvailable
            $ionicActionSheet.show
              buttons: [
                text: 'View in Google Maps'
              ,
                text: 'View in Maps'
              ]
              cancelText: 'Cancel'
              buttonClicked: (index) ->
                place = $scope.place
                if index is 0
                  url = "comgooglemaps://?q=#{place.lat},#{place.long}&zoom=13"
                  $window.open url, '_system'
                else if index is 1
                  url = "maps://?q=#{place.lat},#{place.long}"
                  $window.open url, '_system'
          else
            $ionicActionSheet.show
              buttons: [
                text: 'View in Maps'
              ]
              cancelText: 'Cancel'
              buttonClicked: (index) ->
                if index is 0
                  place = $scope.place
                  url = "maps://?q=#{place.lat},#{place.long}"
                  $window.open url, '_system'
      else
        $ionicActionSheet.show
          buttons: [
            text: 'View in Maps'
          ]
          cancelText: 'Cancel'
          buttonClicked: (index) ->
            if index is 0
              place = $scope.place
              url = "geo:0,0?q=#{place.lat},#{place.long}(#{place.name})"
              $window.open url, '_system'
  ]
]

module.exports = viewPlaceDirective
