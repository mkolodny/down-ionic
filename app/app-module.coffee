require 'angular'
require 'angular-animate' # for ngToast
require 'angular-local-storage'
require 'angular-sanitize' # for ngToast
require 'angular-ui-router'
require 'ng-toast'
require 'ng-cordova'
require './ionic/ionic.js' # for ionic global object
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
require './common/asteroid/asteroid-module'
require './common/resources/resources-module'
require './common/push-notifications/push-notifications-module'
require './event/event-module'
require './my-friends/my-friends-module'
require './add-friends/add-friends-module'
require './friends/friends-module'

angular.module 'down', [
    'ionic'
    'ionic.service.core'
    'ionic.service.deploy'
    'ngCordova'
    'ngToast'
    'down.auth'
    'down.asteroid'
    'down.resources'
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
    'down.addFriends'
    'down.friends'
    'down.pushNotifications'
    'LocalStorageModule'
  ]
  .config ($httpProvider, $ionicConfigProvider, $urlRouterProvider,
           ngToastProvider) ->
    acceptHeader = 'application/json; version=2.0'
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

    # Toasts
    ngToastProvider.configure
      horizontalPosition: 'center'
      animation: 'slide'
      maxNumber: 1
      dismissButton: true
  .run ($cordovaPush, $cordovaStatusbar, $ionicDeploy, $ionicLoading,
        $ionicPlatform, $ionicPopup, $ionicHistory, ngToast,
        $rootScope, $window, Auth, Asteroid, localStorageService, User,
        PushNotifications, $state) ->
    # Check local storage for currentUser and currentPhone
    currentUser = localStorageService.get 'currentUser'
    currentPhone = localStorageService.get 'currentPhone'
    if currentUser isnt null and currentPhone isnt null
      Auth.user = new User currentUser
      Asteroid.login() # re-establish asteroid auth
      for id, friend of Auth.user.friends
        Auth.user.friends[id] = new User friend
      for id, friend of Auth.user.facebookFriends
        Auth.user.facebookFriends[id] = new User friend
      Auth.phone = currentPhone

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

      # Start listening for notifications.
      PushNotifications.listen()

      # Prevent hardware back button from returning
      #   to login views on Android
      $ionicPlatform.registerBackButtonAction (event) ->
        currentState = $state.current.name
        # States where going back is disabled, therefore the
        #   hardware back button should exit the app
        disabledStates = [
          'login'
          'facebookSync'
          'setUsername'
          'findFriends'
          'events'
        ]
        if currentState in disabledStates
          ionic.Platform.exitApp()
        else
          $ionicHistory.goBack()
      , 100 # override action priority 100 (Return to previous view)

      # Update the user's location while they use the app.
      if localStorageService.get('hasRequestedLocationServices') \
          or !ionic.Platform.isIOS()
        Auth.watchLocation()

      Auth.redirectForAuthState()

    $ionicPlatform.ready ->
      # bootstrap()
      # return

      # Check For Updates
      $ionicDeploy.setChannel 'staging' # 'dev', 'staging', 'production'
      $ionicDeploy.check()
        .then (hasUpdate) ->
          if not hasUpdate
            return

          $ionicLoading.show
            template: '''
              <div class="loading-text">Loading...</div>
              <ion-spinner icon="bubbles"></ion-spinner>
              '''

          # Download update
          $ionicDeploy.update()
            .finally ->
              $ionicLoading.hide()
        .finally ->
          bootstrap()
  .constant '$ionicLoadingConfig',
    template: '''
      <ion-spinner icon="bubbles"></ion-spinner>
      '''
