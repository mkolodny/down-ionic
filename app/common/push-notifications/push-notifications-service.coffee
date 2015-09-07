class PushNotifications
  constructor: (@androidSenderID, @$cordovaDevice, @$cordovaPush, @$q,
               @$rootScope, @Auth, @APNSDevice, @GCMDevice, 
               localStorageService, @ngToast) ->
    @localStorage = localStorageService

  register: ->
    deferred = @$q.defer()

    platform = @$cordovaDevice.getPlatform()
    config = null
    if platform is 'iOS'
      # iOS Notification Permissions Options
      config =
        badge: true
        sound: true
        alert: true
    else if platform is 'Android'
      # Android Notification permissions options
      config =
        senderID: @androidSenderID

    @$cordovaPush.register config
      .then (deviceToken) =>
        @saveToken deviceToken
      .then ->
        deferred.resolve()
      , (error) =>
        deferred.reject()

    return deferred.promise

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

    return deferred.promise

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

    # Listen for notifications.
    @$rootScope.$on '$cordovaPush:notificationReceived', @handleNotification

  handleNotification: (event, notification) =>
    platform = @$cordovaDevice.getPlatform()

    # Parse message for each platform
    message = null
    if platform is 'iOS' and notification.alert      
      message = notification.alert
    else if platform is 'Android' \
         and notification.event is 'message'
      message = notification.message

    if message isnt null
      # format message for in app display
      if message.indexOf('from ') is 0
        message = "Down. #{message}"
      @ngToast.create message



module.exports = PushNotifications
