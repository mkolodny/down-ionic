friendshipButtonDirective = ['$state', '$mixpanel', 'Auth', 'Friendship', ($state, $mixpanel, Auth, Friendship) ->
  restrict: 'E'
  scope:
    user: '='
  template: """
    <a class="friendship-button" href="" ng-click="toggleFriendship(user)">
      <i class="icon fa"
         ng-if="!isLoading"
         ng-class="{
          'fa-plus-square-o': !isFriend(user),
          'fa-check-square': isFriend(user),
          }"
      ></i>
      <i class="icon" ng-if="isLoading"
          ><ion-spinner icon="bubbles"></ion-spinner></i>
    </a>
    """
  controller: ['$scope', ($scope) ->

    $scope.isFriend = (user) ->
      Auth.isFriend user.id

    $scope.toggleFriendship = (user) ->
      $scope.isLoading = true

      if Auth.isFriend user.id
        Friendship.deleteWithFriendId user.id
          .$promise.then ->
            # Remove the user from the current user's dictionary of friends.
            delete Auth.user.friends[user.id]
            Auth.setUser Auth.user
            $mixpanel.track 'Remove Friend',
              'from screen': $state.current.name
          .finally ->
            $scope.isLoading = false
      else
        friendship =
          userId: Auth.user.id
          friendId: user.id
        Friendship.save friendship
          .$promise.then ->
            Auth.user.friends[user.id] = user
            Auth.setUser Auth.user
            $mixpanel.track 'Add Friend',
              'from screen': $state.current.name,
              'via sms': user.username is null
          .finally ->
            $scope.isLoading = false
  ]
]

module.exports = friendshipButtonDirective
