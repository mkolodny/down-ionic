friendshipButtonDirective = (Auth, Friendship) ->
  restrict: 'E'
  scope:
    userId: '='
  template: """
    <a href="" ng-click="toggleFriendship(userId)">
      <i class="icon fa friendship-button"
         ng-if="!isLoading"
         ng-class="{
          'fa-plus-square-o': !isFriend(userId),
          'fa-check-square': isFriend(userId),
          }"
      ></i>
      <i class="icon"
         ng-if="isLoading"
      >
        <ion-spinner icon="bubbles"></ion-spinner>
      </i>
    </a>
    """
  controller: ($scope) ->
    $scope.isFriend = (userId) ->
      Auth.isFriend userId

    $scope.toggleFriendship = (userId) ->
      $scope.isLoading = true

      if Auth.isFriend userId
        Friendship.deleteWithFriendId(userId).finally ->
          $scope.isLoading = false
      else
        friendship =
          userId: Auth.user.id
          friendId: userId
        Friendship.save(friendship).$promise.finally ->
          $scope.isLoading = false

module.exports = friendshipButtonDirective
