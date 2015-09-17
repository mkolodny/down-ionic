class PushNotifications
  @$inject: ['$cordovaDevice', '$cordovaPush', '$q', '$rootScope', '$window',
             'androidSenderID', 'Auth', 'APNSDevice', 'GCMDevice',
             'localStorageService', 'ngToast']
  constructor: (@$cordovaDevice, @$cordovaPush, @$q, @$rootScope, @$window,
                @androidSenderID, @Auth, @APNSDevice, @GCMDevice,
                localStorageService, @ngToast) ->
    @localStorage = localStorageService

  listen: ->
    platform = @$cordovaDevice.getPlatform()

    if platform is 'iOS'
      # If we've already asked the user for push notifications permissions,
      #   register the `$cordovaPush` module so that we can send them in-app
      #   notifications. This is required to start listening for notifications.
      if @localStorage.get 'hasRequestedPushNotifications'
        @register()

      # Listen for notifications.
      @$rootScope.$on '$cordovaPush:notificationReceived', @handleNotification
    else if platform is 'Android'
      @registerAndroid()

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

  registerAndroid: ->
    options =
      android:
        senderID: @androidSenderID
        icon: 'push_icon'
        iconColor: '#6A38AB'
    push = @$window.PushNotification.init options
    push.on 'registration', @handleRegistrationAndroid
    push.on 'notification', @handleNotificationAndroid

  handleRegistrationAndroid: (data) =>
    deviceToken = data.registrationId
    @saveToken deviceToken

  handleNotificationAndroid: (data) =>
    if data.message
      message = data.message
      # format message for in app display
      if message.indexOf('from ') is 0
        message = "Down. #{message}"
      @ngToast.create message

      # Refresh UI because scope changed happened
      #   outside angular lifecycle
      if not @$rootScope.$$phase
        @$rootScope.$digest()

  register: ->
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

    deferred.promise

  handleNotification: (event, notification) =>
    platform = @$cordovaDevice.getPlatform()

    message = null
    if platform is 'iOS' and notification.alert
      message = notification.alert

    if message isnt null
      # format message for in app display
      if message.indexOf('from ') is 0
        message = "Down. #{message}"
      @ngToast.create message

module.exports = PushNotifications
