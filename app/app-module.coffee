require 'angular-local-storage'
require 'ng-toast'
require 'ng-cordova'
# Lib
require './ionic/angular-ios9-uiwebview.patch.js'
require './ionic/ionic.io.min.js'
require './vendor/mixpanel/mixpanel-jslib-snippet'
# Common
require './common/local-db/local-db-module'
require './common/mixpanel/mixpanel-module'
require './common/auth/auth-module'
require './common/env/env-module'
require './common/meteor/meteor'
require './common/resources/resources-module'
require './common/push-notifications/push-notifications-module'
# Views
require './tabs/tabs-module'
require './login/login-module'
require './verify-phone/verify-phone-module'
require './facebook-sync/facebook-sync-module'
require './set-username/set-username-module'
require './request-push/request-push-module'
require './request-location/request-location-module'
require './request-contacts/request-contacts-module'
require './find-friends/find-friends-module'
require './chats/chats-module'
require './add-by-phone/add-by-phone-module'
require './add-by-username/add-by-username-module'
require './add-from-address-book/add-from-address-book-module'
require './add-from-facebook/add-from-facebook-module'
require './my-friends/my-friends-module'
require './add-friends/add-friends-module'
require './friends/friends-module'
require './added-me/added-me-module'
require './friend-chat/friend-chat-module'
require './create-event/create-event-module'
require './tutorial/tutorial-module'
require './team/team-module'
require './events/events-module'
require './comments/comments-module'
require './my-events/my-events-module'
require './interested/interested-module'

angular.module 'rallytap', [
    'analytics.mixpanel'
    'ionic'
    'ionic.service.core'
    'ionic.service.deploy'
    'ngCordova'
    'ngToast'
    'rallytap.tabs'
    'rallytap.auth'
    'rallytap.env'
    'rallytap.resources'
    'rallytap.login'
    'rallytap.verifyPhone'
    'rallytap.facebookSync'
    'rallytap.setUsername'
    'rallytap.requestPush'
    'rallytap.requestLocation'
    'rallytap.requestContacts'
    'rallytap.findFriends'
    'rallytap.chats'
    'rallytap.addByPhone'
    'rallytap.addByUsername'
    'rallytap.addFromAddressBook'
    'rallytap.addFromFacebook'
    'rallytap.addedMe'
    'rallytap.myFriends'
    'rallytap.addFriends'
    'rallytap.friends'
    'rallytap.pushNotifications'
    'rallytap.friendChat'
    'rallytap.createEvent'
    'rallytap.localDB'
    'rallytap.tutorial'
    'rallytap.team'
    'rallytap.events'
    'rallytap.comments'
    'rallytap.myEvents'
    'rallytap.interested'
    'LocalStorageModule'
    'ngIOS9UIWebViewPatch'
  ]
  .config ($httpProvider, $ionicConfigProvider, $mixpanelProvider,
           $urlRouterProvider, $stateProvider, mixpanelToken, ngToastProvider) ->
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

    # Init mixpanel
    $mixpanelProvider.apiKey mixpanelToken

    # Toasts
    ngToastProvider.configure
      horizontalPosition: 'center'
      animation: 'slide'
      maxNumber: 1
      dismissButton: true

  .run ($cordovaPush, $cordovaStatusbar, $ionicDeploy, $ionicLoading,
        $ionicPlatform, $ionicPopup, $ionicHistory, $mixpanel,
        $rootScope, $state, $timeout, $window, Auth, branchKey,
        localStorageService, LocalDB, ionicDeployChannel, PushNotifications,
        skipIonicDeploy, User) ->
    ###
    Put anything that touches Cordova in here!
    ###
    bootstrap = ->
      # Init the localDB
      LocalDB.init().then ->
        # Resume session from localStorage
        Auth.resumeSession()
      .then ->
        # Hide the accessory bar by default (remove this to show the accessory bar
        # above the keyboard for form inputs)
        $window.cordova?.plugins.Keyboard?.hideKeyboardAccessoryBar true

        # Fix this problem:
        #   http://stackoverflow.com/questions/29846816/space-made-for-two-keyboards-in-ionic-on-ios
        $window.cordova?.plugins.Keyboard?.disableScroll true

        # Make the status bar white.
        if angular.isDefined $window.StatusBar
          $cordovaStatusbar.overlaysWebView true
          $cordovaStatusbar.style 1

        # Start a Branch session.
        if angular.isDefined $window.branch
          $window.branch.init branchKey, (err, data) ->

        # Start listening for notifications.
        if angular.isDefined $window.device
          PushNotifications.listen()

        # Prevent hardware back button from returning
        #   to login views on Android
        #   TODO : update states
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

        $ionicPlatform.on 'resume', ->
          # Track App Opens
          $mixpanel.track 'Open App'

          # Update the user's friend list in case a user 
          #   they added by phone number signed up.
          Auth.getFriends()
          
          # Update the user for an accurate point count
          Auth.getMe().then (user) ->
            Auth.setUser user

        # Update the user's location while they use the app.
        if Auth.flags.hasRequestedLocationServices \
            or !ionic.Platform.isIOS()
          Auth.watchLocation()

        $rootScope.finishedBootstrap = true
        Auth.redirectForAuthState()

    $ionicPlatform.ready ->
      # Skip Downloading Updates During Development
      if skipIonicDeploy
        console.log 'Skipping Ionic Deploy'
        bootstrap()
        return

      # Check For Updates
      $ionicDeploy.setChannel ionicDeployChannel
      $ionicDeploy.check()
        .then (hasUpdate) ->
          if not hasUpdate
            # No update
            bootstrap()
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
              bootstrap()
        , ->
          # Error checking for update
          bootstrap()

  .constant '$ionicLoadingConfig',
    template: '''
      <ion-spinner icon="bubbles"></ion-spinner>
      '''
