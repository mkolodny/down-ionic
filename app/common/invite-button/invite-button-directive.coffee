inviteButtonDirective = ->
  restrict: 'E'
  scope:
    user: '='
    event: '='
  bindToController: true
  templateUrl: 'app/common/invite-button/invite-button.html'
  controller: 'inviteButtonCtrl as inviteButton'

module.exports = inviteButtonDirective
