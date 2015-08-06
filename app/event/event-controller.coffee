class Event
  constructor: (@$state, @$stateParams, @Invitation) ->
    @invitation = @$stateParams.invitation
    @event = @invitation.event

    @Invitation.getEventInvitations {id: @event.id}
      .$promise.then (invitations) =>
        @members = (invitation.toUser for invitation in invitations)
      , =>
        # Mock the members for now.
        @members = [
          id: 1
          name: 'Michael Kolodny'
          imageUrl: 'https://graph.facebook.com/v2.2/4900498025333/picture'
        ,
          id: 1
          name: 'Andrew Linfoot'
          imageUrl: 'https://graph.facebook.com/v2.2/10155438985280433/picture'
        ]
        return
        @membersError = true

  toggleIsHeaderExpanded: ->
    if @isHeaderExpanded
      @isHeaderExpanded = false
    else
      @isHeaderExpanded = true

  isAccepted: ->
    @invitation.response is @Invitation.accepted

  isMaybe: ->
    @invitation.response is @Invitation.maybe

  acceptInvitation: ->
    response = @invitation.response
    @invitation.response = @Invitation.accepted
    @Invitation.update @invitation
      .$promise.then =>
        null
      , =>
        @invitation.response = response

  maybeInvitation: ->
    response = @invitation.response
    @invitation.response = @Invitation.maybe
    @Invitation.update @invitation
      .$promise.then =>
        null
      , =>
        @invitation.response = response

  declineInvitation: ->
    response = @invitation.response
    @invitation.response = @Invitation.declined
    @Invitation.update @invitation
      .$promise.then =>
        null
      , =>
        @invitation.response = response

    @$state.go 'events'

module.exports = Event
