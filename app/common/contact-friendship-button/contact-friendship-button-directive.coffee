require '../../vendor/intl-phone/libphonenumber-utils.js'

contactFriendshipButtonDirective = (UserPhone) ->
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

      UserPhone.create($scope.contact).then (data) ->
        # Update the contact on the scope. It should now have a nationalPhone
        # property.
        $scope.contact = data.contact
      , ->
        $scope.isLoading = false

module.exports = contactFriendshipButtonDirective
