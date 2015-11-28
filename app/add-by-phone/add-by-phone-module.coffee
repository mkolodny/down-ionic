require '../common/auth/auth-module'
require '../common/friendship-button/friendship-button-module'
require '../common/resources/resources-module'
require '../common/intl-phone/intl-phone-module'
AddByPhoneCtrl = require './add-by-phone-controller'

angular.module 'rallytap.addByPhone', [
    'ui.router'
    'rallytap.auth'
    'rallytap.intlPhone'
    'rallytap.resources'
    'rallytap.friendshipButton'
  ]
  .config ($stateProvider) ->
    $stateProvider.state 'tabs.friends.addByPhone',
      url: '/add-by-phone'
      templateUrl: 'app/add-by-phone/add-by-phone.html'
      controller: 'AddByPhoneCtrl as addByPhone'
  .controller 'AddByPhoneCtrl', AddByPhoneCtrl
