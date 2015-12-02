class CreateEventCtrl
  @$inject: ['$cordovaDatePicker', '$filter', '$ionicLoading', '$ionicHistory',
             '$ionicModal', '$rootScope', '$scope', '$state',
             'Auth', 'Event', 'ngToast', '$ionicActionSheet']
  constructor: (@$cordovaDatePicker, @$filter, @$ionicLoading, @$ionicHistory,
                @$ionicModal, @$rootScope, @$scope, @$state,
                @Auth, @Event, @ngToast, @$ionicActionSheet) ->
    # Init the view.
    @currentUser = @Auth.user

    @$scope.$on '$ionicView.afterEnter', =>
      @$rootScope.hideNavBottomBorder = true

    @$scope.$on '$ionicView.leave', =>
      @$rootScope.hideNavBottomBorder = false

    # Init the set place modal.
    @$ionicModal.fromTemplateUrl 'app/set-place/set-place.html',
        scope: @$scope
        animation: 'slide-in-up'
      .then (modal) =>
        @setPlaceModal = modal

    # Set functions to control the place modal on the scope so that they can be
    # called from inside the modal.
    @$scope.hidePlaceModal = =>
      @setPlaceModal.hide()

    # Clean up the set place modal after hiding it.
    @$scope.$on '$destroy', =>
      @setPlaceModal.remove()

    @$scope.$on 'placeAutocomplete:placeChanged', (event, place) =>
      @place =
        name: place.name
        lat: place.geometry.location.lat()
        long: place.geometry.location.lng()
      @$scope.hidePlaceModal()

  showSetPlaceModal: ->
    @setPlaceModal.show()

  showDatePicker: ->
    options =
      mode: 'datetime' # This can be anything other than 'date' or 'time'
      allowOldDates: false
      doneButtonLabel: 'Set Date'
    if @datetime
      options.date = @datetime
    else
      options.date = new Date()
    @$cordovaDatePicker.show options
      .then (date) =>
        @datetime = date
        @dateString = @$filter('date') @datetime, "EEE, MMM d 'at' h:mm a"

  getNewEvent: ->
    newEvent = {}
    newEvent.title = @title
    if @datetime
      newEvent.datetime = @datetime
    if @place
      newEvent.place = @place
    if angular.isDefined @friendsOnly
      newEvent.friendsOnly = @friendsOnly
    newEvent

  createEvent: ->
    @$ionicLoading.show()

    newEvent = @getNewEvent()
    @Event.save newEvent
      .$promise.then (event) =>
        # Clear form
        delete @title
        delete @datetime
        delete @place

        @$state.go 'events'
      , =>
        @ngToast.create 'Oops... an error occurred.'
      .finally =>
        @$ionicLoading.hide()

  changePrivacy: ->
    @hideActionSheet = @$ionicActionSheet.show
        buttons: [
          text: '<i class="fa fa-link"></i> Connections'
        ,
          text: '<i class="fa fa-users"></i> Friends'
        ]
        cancelText: 'Cancel'
        buttonClicked: @selectPrivacy

  selectPrivacy: (actionSheetIndex) =>
    if actionSheetIndex is 0
      @friendsOnly = false
    else if actionSheetIndex is 1
      @friendsOnly = true

    @hideActionSheet()

module.exports = CreateEventCtrl
