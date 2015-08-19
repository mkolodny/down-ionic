require '../../vendor/intl-phone/libphonenumber-utils.js'

contactFriendshipButtonDirective = (Auth, UserPhone) ->
  restrict: 'E'
  scope:
    contact: '='
  template: """
    <a href="" ng-click="addFriend()">
      <i class="icon fa friendship-button fa-plus-square-o"
        ng-if="!isLoading"></i>
      <i class="icon"
        ng-if="isLoading">
        <ion-spinner icon="bubbles"></ion-spinner>
      </i>
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
          Auth.setUser Auth.user
        , ->
          $scope.isLoading = false

module.exports = contactFriendshipButtonDirective
