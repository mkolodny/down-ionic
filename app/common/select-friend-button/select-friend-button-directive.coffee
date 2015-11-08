selectFriendButtonDirective = ['$rootScope', '$state', '$meteor', '$mixpanel', 'ngToast', \
    ($rootScope, $state, $meteor, $mixpanel, ngToast) ->
  restrict: 'E'
  scope:
    user: '='
  template: """
    <a href=""
       class="match-button icon"
       ng-click="selectFriend(user); $event.stopPropagation()"
       ng-class="{'selected': isSelected(user)}">
      <canvas ng-if="isSelected(user) && !isLoading"
              class="chart chart-pie friend-select-pie"
              data="[
                (100 - percentRemaining(user)),
                percentRemaining(user)
              ]"
              labels="['', '']"
              colours="['#ffffff', 'rgba(0,0,0,0)']"
              width="30" height="30"
              options="{
                segmentShowStroke: false,
                animation: false,
                responsive: false,
                showTooltips: false
              }"
              ></canvas>
      <i ng-if="!isLoading" class="fa fa-hand-o-up"></i>
      <i ng-if="!isLoading" class="fa fa-circle-thin"></i>
      <i ng-if="!isLoading" class="fa fa-circle"></i>
      <i class="icon" ng-if="isLoading">
        <ion-spinner icon="bubbles"></ion-spinner>
      </i>
    </a>
    """
  controller: ['$scope', ($scope) ->
    FriendSelects = $meteor.getCollectionByName 'friendSelects'

    $scope.isSelected = (user) ->
      $scope.percentRemaining(user) isnt 0

    $scope.selectFriend = (user) ->
      if $scope.isSelected(user) then return

      $scope.isLoading = true
      $meteor.call 'selectFriend', "#{user.id}"
        .then (isMatch) ->
          $mixpanel.track 'Select Friend'
          if isMatch
            $rootScope.$broadcast 'selectFriendButton.newMatch', user
          else
            $scope.tempPercentRemaing = 100
        , ->
          ngToast.create 'Oops, an error occurred.'
        .finally ->
          $scope.isLoading = false

    $scope.percentRemaining = (user) ->
      friendSelect = FriendSelects.findOne
        friendId: "#{user.id}"
      # temp percent remaining used to provide latency
      #   compensation when creating a new friend select
      tempPercentRemaing = $scope.tempPercentRemaing
      if friendSelect is undefined and \
         tempPercentRemaing is undefined
        # Not selected
        return 0
      else if angular.isDefined(tempPercentRemaing) and \
              friendSelect is undefined
        # Just selected but friend select object
        #   not on the client yet
        return tempPercentRemaing
      else
        # Remove tempPercentRemaing so friendSelect
        #   object is source of truth
        delete $scope.tempPercentRemaing

        # Add an exception for teamrallytap.
        if friendSelect.expiresAt is undefined
          return 100

        now = new Date().getTime()
        timeRemaining = friendSelect.expiresAt.getTime() - now
        sixHours = 1000 * 60 * 60 * 6
        return Math.round (timeRemaining / sixHours) * 100
  ]
]

module.exports = selectFriendButtonDirective
