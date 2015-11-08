class CreateEventCtrl
  @$inject: ['$cordovaDatePicker', '$filter', '$ionicActionSheet',
             '$ionicHistory', '$ionicModal', '$scope', '$state', '$window']
  constructor: (@$cordovaDatePicker, @$filter, @$ionicActionSheet,
                @$ionicHistory, @$ionicModal, @$scope, @$state, @$window) ->
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

    @$scope.$on '$ionicView.enter', =>
      # Don't animate the transition to the invite friends view.
      @$ionicHistory.nextViewOptions
        disableAnimate: true

    # Set the minimum accepted options.
    options = (option for option in [2..20])
    for option in [25..100] by 5
      options.push option
    @minAcceptedOptions = ({value: option, name: "#{option} People Minimum"} \
        for option in options)

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

  inviteFriends: ->
    newEvent = @getNewEvent()
    @$state.go 'inviteFriends', {event: newEvent}

  getNewEvent: ->
    newEvent = {}
    if @title
      newEvent.title = @title
    else
      newEvent.title = 'hang out'
    if @datetime
      newEvent.datetime = @datetime
    if @place
      newEvent.place = @place
    if @minAccepted
      newEvent.minAccepted = @minAccepted
    newEvent

  showMoreOptions: ->
    hideSheet = null
    options =
      buttons: [
        text: 'Set Minimum # of People'
      ]
      cancelText: 'Cancel'
      buttonClicked: (index) =>
        if index is 0
          @showMinAccepted = true
          hideSheet()

    hideSheet = @$ionicActionSheet.show options

module.exports = CreateEventCtrl
