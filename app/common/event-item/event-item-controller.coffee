class EventItemCtrl
  @$inject: ['$state', 'Auth', 'SavedEvent', 'ngToast']
  constructor: (@$state, @Auth, @SavedEvent, @ngToast) ->

  saveEvent: ->
    # For latency compensation
    @savedEvent.interestedFriends = []
    @savedEvent.totalNumInterested++

    newSavedEvent =
      userId: @Auth.user.id
      eventId: @savedEvent.eventId
    @SavedEvent.save newSavedEvent
      .$promise.then (newSavedEvent) =>
        @savedEvent.interestedFriends = newSavedEvent.interestedFriends
      , =>
        # Revert latency compensation
        delete @savedEvent.interestedFriends
        @savedEvent.totalNumInterested--
  
        @ngToast.create 'Oops.. an error occurred..'

  didUserSaveEvent: ->
    angular.isArray @savedEvent.interestedFriends

  viewComments: ->
    @$state.go 'comments',
      id: @savedEvent.event.id
      event: @savedEvent.event

  viewInterested: ->
    @$state.go 'interested',
      id: @savedEvent.event.id
      event: @savedEvent.event

module.exports = EventItemCtrl
