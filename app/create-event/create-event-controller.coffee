class CreateEventCtrl
  @$inject: ['$cordovaDatePicker', '$filter', '$ionicHistory', '$ionicModal',
             '$scope', '$state']
  constructor: (@$cordovaDatePicker, @$filter, @$ionicHistory, @$ionicModal,
                @$scope, @$state) ->
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
      newEvent.title = 'Let\'s do something!'
    if @datetime
      newEvent.datetime = @datetime
    if @place
      newEvent.place = @place
    newEvent

module.exports = CreateEventCtrl
