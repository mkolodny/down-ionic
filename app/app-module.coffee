require 'angular'
require 'angular-ui-router'
require 'angular-local-storage'
require 'ng-cordova'
require './ionic/ionic-core.js'
require './ionic/ionic-deploy.js'
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
require './add-by-username/add-by-username-module'
require './add-from-address-book/add-from-address-book-module'
require './add-from-facebook/add-from-facebook-module'
require './common/auth/auth-module'
require './event/event-module'
require './my-friends/my-friends-module'
require './friends/friends-module'

angular.module 'down', [
    'ionic'
    'ionic.service.core'
    'ionic.service.deploy'
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
    'down.addByUsername'
    'down.addFromAddressBook'
    'down.addFromFacebook'
    'down.event'
    'down.myFriends'
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

    # Show no text by default on the back button.
    $ionicConfigProvider.backButton.text ''
      .previousTitleText false
  .run ($cordovaPush, $cordovaStatusbar, $ionicDeploy, $ionicLoading,
        $ionicPlatform, $rootScope, $window, Auth, localStorageService) ->
    # Check local storage for currentUser and currentPhone
    currentUser = localStorageService.get 'currentUser'
    currentPhone = localStorageService.get 'currentPhone'
    if currentUser isnt null and currentPhone isnt null
      Auth.user = currentUser
      Auth.phone = currentPhone

    # Listen for notifications.
    $rootScope.$on '$cordovaPush:notificationReceived', (event, notification) ->
      if notification.alert
        # TODO: Use https://github.com/jirikavi/AngularJS-Toaster to show a
        #   notification.
        null

      if notification.sound
        sound = new Media(event.sound)
        sound.play()

    ###
    Put anything that touches Cordova in here!
    ###
    bootstrap = ->
      # Hide the accessory bar by default (remove this to show the accessory bar
      # above the keyboard for form inputs)
      $window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar true

      # Fix this problem:
      #   http://stackoverflow.com/questions/29846816/space-made-for-two-keyboards-in-ionic-on-ios
      $window.cordova?.plugins.Keyboard?.disableScroll true

      # Make the status bar white.
      $cordovaStatusbar.overlaysWebView true
      $cordovaStatusbar.style 1

      # Start a Branch session.
      # Staging
      #branch.init 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv', (err, data) ->
      # Production
      branch.init 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ', (err, data) ->

      # If we've already asked the user for push notifications permissions,
      #   register the `$cordovaPush` module so that we can send them in-app
      #   notifications.
      if localStorageService.get('hasRequestedPushNotifications')
        iosConfig =
          badge: true
          sound: true
          alert: true
        $cordovaPush.register iosConfig

      Auth.redirectForAuthState()

    $ionicPlatform.ready ->
      # Check For Updates
      #Auth.redirectForAuthState()
      $ionicDeploy.setChannel 'staging' # 'dev', 'staging', 'production'
      $ionicDeploy.check().then (hasUpdate) ->
        if hasUpdate
          $ionicLoading.show()

          # Download update
          $ionicDeploy.update().finally ->
            $ionicLoading.hide()
      .finally ->
        bootstrap()
