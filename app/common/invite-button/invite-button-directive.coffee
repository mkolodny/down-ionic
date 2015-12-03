inviteButtonDirective = ['$state', '$meteor', '$mixpanel', 'Auth', \
                         'Friendship', 'ngToast', \
                         ($state, $meteor, $mixpanel, Auth, Friendship, ngToast) ->
  restrict: 'E'
  scope:
    user: '='
    event: '='
  template: """
    <a ng-mousedown="inviteUser(user, event)"
       ng-if="!hasBeenInvited(user, event)"
       class="button invite"
       ng-class="{
        'invited': hasBeenInvited(user, event)
       }">
      <span ng-if="!isLoading">
        Down?
      </span>
      <i class="icon" ng-if="isLoading">
        <ion-spinner icon="bubbles"></ion-spinner>
      </i>
    </a>
    <button class="button button-clear invite sent-invite"
            ng-if="hasBeenInvited(user, event)"
            disabled>
      Message sent
    </button>
    """
  controller: ['$scope', ($scope) ->
    Messages = $meteor.getCollectionByName 'messages'

    $scope.hasBeenInvited = (user, event) ->
      chatId = Friendship.getChatId user.id
      selector =
        chatId: chatId
        type: 'invite_action'
        'meta.event.id': event.id
      angular.isDefined Messages.findOne(selector)

    $scope.inviteUser = (user, event) ->
      $scope.isLoading = true

      creator =
        id: "#{Auth.user.id}"
        name: Auth.user.name
        firstName: Auth.user.firstName
        lastName: Auth.user.lastName
        imageUrl: Auth.user.imageUrl
      $meteor.call('sendEventInvite', creator, "#{user.id}", event)
        .then ->
          $scope.trackInvite user
        , ->
          ngToast.create 'Oops, an error occurred.'
        .finally ->
          $scope.isLoading = false

    $scope.trackInvite = (user) ->
      $mixpanel.track 'Send Invite',
        'is friend': Auth.isFriend user.id
        'from screen': $state.current.name

  ]
]

module.exports = inviteButtonDirective
