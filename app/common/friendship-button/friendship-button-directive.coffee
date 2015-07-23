friendshipButtonDirective = (Auth, Friendship) ->
  restrict: 'E'
  scope:
    userId: '='
  template: """
    <a href="" ng-click="toggleFriendship(userId)">
      <i class="icon fa"
         ng-class="{'fa-plus-square-o': !isFriend(userId) && !isLoading, 'fa-check-square': isFriend(userId) && !isLoading, 'fa-spinner': isLoading, 'fa-pulse': isLoading}"></i>
    </a>
    """
  controller: ($scope) ->
    $scope.isFriend = (userId) ->
      Auth.isFriend userId

    $scope.toggleFriendship = (userId) ->
      $scope.isLoading = true

      if Auth.isFriend userId
        Friendship.deleteWithFriendId(userId).then ->
          $scope.isLoading = false
        , ->
          $scope.isLoading = false
      else
        friendship =
          userId: Auth.user.id
          friendId: userId
        Friendship.save(friendship).$promise.then ->
          $scope.isLoading = false
        , ->
          $scope.isLoading = false

module.exports = friendshipButtonDirective
