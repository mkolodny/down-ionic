class PushNotifications
  @$inject: ['$cordovaDevice', '$cordovaPush', '$q', '$rootScope', '$window',
             'androidSenderID', 'Auth', 'APNSDevice', 'GCMDevice',
             'localStorageService', 'ngToast']
  constructor: (@$cordovaDevice, @$cordovaPush, @$q, @$rootScope, @$window,
                @androidSenderID, @Auth, @APNSDevice, @GCMDevice,
                localStorageService, @ngToast) ->
    @localStorage = localStorageService

  saveToken: (deviceToken)->
    deferred = @$q.defer()

    device = @$cordovaDevice.getDevice()
    name = "#{device.model}, #{device.version}"
    pushDevice =
      userId: @Auth.user.id
      registrationId: deviceToken
      deviceId: device.uuid
      name: name
    if device.platform is 'iOS'
      @APNSDevice.save pushDevice
        .$promise.then =>
          deferred.resolve()
        .finally =>
          deferred.reject()
    else if device.platform is 'Android'
      @GCMDevice.save pushDevice
        .$promise.then =>
          deferred.resolve()
        .finally =>
          deferred.reject()

    deferred.promise

  listen: ->
    platform = @$cordovaDevice.getPlatform()

    if platform is 'iOS'
      # If we've already asked the user for push notifications permissions,
      #   register the `$cordovaPush` module so that we can send them in-app
      #   notifications. This is required to start listening for notifications.
      if @localStorage.get 'hasRequestedPushNotifications'
        @register()

    else if platform is 'Android'
      @register()

  register: ->
    # Check if using the old plugin
    if @$window.PushNotification.init is undefined
      @registerWithOldPlugin()
      return

    options =
      android:
        senderID: @androidSenderID
        icon: 'push_icon'
        iconColor: '#6A38AB'
      ios:
        alert: true
        badge: true
        sound: true

    push = @$window.PushNotification.init options
    push.on 'registration', @handleRegistration
    push.on 'notification', @handleNotification

  handleRegistration: (data) =>
    deviceToken = data.registrationId
    @saveToken deviceToken

  handleNotification: (data) =>
    if data.message
      message = data.message
      # format message for in app display
      if message.indexOf('from ') is 0
        message = "Down? #{message}"
      @ngToast.create message

      # Refresh UI because scope changed happened
      #   outside angular lifecycle
      if not @$rootScope.$$phase
        @$rootScope.$digest()



  ###
  #  Old Plugin Methods - iOS only
  ###
  registerWithOldPlugin: ->
    deferred = @$q.defer()

    # iOS Notification Permissions Options
    config =
      badge: true
      sound: true
      alert: true

    @$cordovaPush.register config
      .then (deviceToken) =>
        @saveToken deviceToken
      .then ->
        deferred.resolve()
      , (error) =>
        deferred.reject()

    # Listen for notifications.
    @$rootScope.$on('$cordovaPush:notificationReceived',
        @handleNotificationWithOldPlugin)

    deferred.promise

  handleNotificationWithOldPlugin: (event, notification) =>
    message = notification.alert

    if angular.isDefined message
      # format message for in app display
      if message.indexOf('from ') is 0
        message = "Down? #{message}"
      @ngToast.create message

module.exports = PushNotifications
