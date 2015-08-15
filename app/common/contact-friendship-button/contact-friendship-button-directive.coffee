require '../../vendor/intl-phone/libphonenumber-utils.js'

contactFriendshipButtonDirective = (Auth, UserPhone) ->
  restrict: 'E'
  scope:
    contact: '='
  template: """
    <a href="" ng-click="addFriend()">
      <i class="icon fa friendship-button"
         ng-class="{'fa-plus-square-o': !isLoading, 'fa-spinner': isLoading, 'fa-pulse': isLoading}"
         ></i>
    </a>
    """
  controller: ($scope) ->
    $scope.addFriend = ->
      $scope.isLoading = true

      UserPhone.create $scope.contact
        .then (data) ->
          $scope.contact = data.contact

          friend = data.userphone.user
          Auth.user.friends[friend.id] = friend
        , ->
          $scope.isLoading = false

module.exports = contactFriendshipButtonDirective
