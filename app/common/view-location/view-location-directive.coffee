viewLocationDirective = ['$ionicActionSheet', '$window', ($ionicActionSheet, $window) ->
  restrict: 'A'
  scope:
    location: '='
  template: '<span ng-click="showActionSheet()" ng-transclude></span>'
  transclude: true
  controller: ($scope) ->
    $scope.showActionSheet = ->
      $window.appAvailability.checkBool 'comgooglemaps://', \
          (googleMapsIsAvailable) ->
        if googleMapsIsAvailable
          $ionicActionSheet.show
            buttons: [
              text: 'View in Google Maps'
            ,
              text: 'View in Maps'
            ]
            cancelText: 'Cancel'
            buttonClicked: (index) ->
              location = $scope.location
              if index is 0
                url = "comgooglemaps://?q=#{location.lat},#{location.long}&zoom=13"
                $window.open url, '_system'
              else if index is 1
                url = "maps://?q=#{location.lat},#{location.long}"
                $window.open url, '_system'
        else
          $ionicActionSheet.show
            buttons: [
              text: 'View in Maps'
            ]
            cancelText: 'Cancel'
            buttonClicked: (index) ->
              if index is 0
                location = $scope.location
                url = "maps://?q=#{location.lat},#{location.long}"
                $window.open url, '_system'
]

module.exports = viewLocationDirective
