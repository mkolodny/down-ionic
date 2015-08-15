require 'angular'
require 'angular-ui-router'
require 'angular-local-storage'
require 'ng-cordova'
require './login/login-module'
require './verify-phone/verify-phone-module'
require './facebook-sync/facebook-sync-module'
require './set-username/set-username-module'
require './request-push/request-push-module'
require './request-location/request-location-module'
require './request-contacts/request-contacts-module'
require './find-friends/find-friends-module'
require './events/events-module'
require './invite-friends/invite-friends-module'
require './add-friends/add-friends-module'
require './add-by-username/add-by-username-module'
require './add-from-address-book/add-from-address-book-module'
require './add-from-facebook/add-from-facebook-module'
require './common/auth/auth-module'
require './event/event-module'
require './friends/friends-module'

angular.module 'down', [
    'ionic'
    'ngCordova'
    'down.auth'
    'down.login'
    'down.verifyPhone'
    'down.facebookSync'
    'down.setUsername'
    'down.requestPush'
    'down.requestLocation'
    'down.requestContacts'
    'down.findFriends'
    'down.events'
    'down.inviteFriends'
    'down.addFriends'
    'down.addByUsername'
    'down.addFromAddressBook'
    'down.addFromFacebook'
    'down.event'
    'down.friends'
    'LocalStorageModule'
  ]
  .config ($httpProvider, $ionicConfigProvider, $urlRouterProvider) ->
    acceptHeader = 'application/json; version=1.2'
    $httpProvider.defaults.headers.common['Accept'] = acceptHeader
    $httpProvider.interceptors.push ($injector) ->
      # Include the Authorization header in each request.
      request: (config) ->
        # Delay injecting the $http + Auth services to avoid a circular
        #   dependency.
        Auth = $injector.get 'Auth'
        if Auth.user.authtoken?
          authHeader = "Token #{Auth.user.authtoken}"
          config.headers.Authorization = authHeader
        config
    $ionicConfigProvider.backButton.text ''
      .previousTitleText false
  .run ($cordovaStatusbar, $ionicPlatform, $window, Auth, localStorageService) ->
    $ionicPlatform.ready ->
      # Check local storage for currentUser
      currentUser = localStorageService.get 'currentUser'
      if currentUser isnt null
        Auth.user = currentUser
      Auth.redirectForAuthState()

      # Hide the accessory bar by default (remove this to show the accessory bar
      # above the keyboard for form inputs)
      $window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar true

      # Fix this problem:
      #   http://stackoverflow.com/questions/29846816/space-made-for-two-keyboards-in-ionic-on-ios
      $window.cordova?.plugins.Keyboard?.disableScroll true

      # Make the status bar white.
      $cordovaStatusbar.overlaysWebView true
      $cordovaStatusbar.style 1

