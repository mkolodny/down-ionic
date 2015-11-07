LinkInvitation = ['$cordovaSocialSharing', '$ionicLoading', '$ionicPopup', '$mixpanel',\
                  '$resource', '$window', 'apiRoot', '$state', \
                  'Auth', 'Event', 'Invitation', 'User', 'ngToast', \
                  ($cordovaSocialSharing, $ionicLoading, $ionicPopup, \
                   $mixpanel, $resource, $window, apiRoot, $state, \
                   Auth, Event, Invitation, User, ngToast) ->
  listUrl = "#{apiRoot}/link-invitations"

  serializeLinkInvitation = (linkInvitation) ->
    data =
      event: linkInvitation.eventId
      from_user: linkInvitation.fromUserId
    data
  deserializeLinkInvitation = (response) ->
    linkInvitation =
      linkId: response.link_id
      createdAt: new Date response.created_at
    if angular.isNumber response.event
      linkInvitation.eventId = response.event
    else
      linkInvitation.eventId = response.event.id
      linkInvitation.event = Event.deserialize response.event
    if angular.isNumber response.from_user
      linkInvitation.fromUserId = response.from_user
    else
      linkInvitation.fromUserId = response.from_user.id
      linkInvitation.fromUser = User.deserialize response.from_user
    if angular.isObject response.invitation
      linkInvitation.invitationId = response.invitationId
      linkInvitation.invitation = Invitation.deserialize response.invitation
    linkInvitation

  resource = $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request = serializeLinkInvitation data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeLinkInvitation data

    getByLinkId:
      method: 'get'
      url: "#{listUrl}/:linkId"
      params:
        linkId: '@linkId'
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        if angular.isDefined data.detail # There was an error.
          return null
        deserializeLinkInvitation data

  resource.serialize = serializeLinkInvitation
  resource.deserialize = deserializeLinkInvitation

  resource.share = (event) ->
    $ionicLoading.show()

    linkInvitation =
      eventId: event.id
      fromUserId: Auth.user.id
    @save linkInvitation
      .$promise.then (linkInvitation) =>
        $mixpanel.track 'Get Link Invitation',
          'from screen': $state.current.name
        groupLink = "https://rallytap.com/e/#{linkInvitation.linkId}"
        # Show a "Copy Group Link" popup when the social sharing plugin isn\'t
        #   installed for backwards compatibility.
        if angular.isDefined $window.plugins?.socialsharing
          eventMessage = event.getEventMessage()
          $cordovaSocialSharing.share eventMessage, eventMessage, null, groupLink
        else
          $ionicPopup.alert
            title: 'Copy Group Link'
            template: """
              <input id="share-link" value="#{groupLink}">
              """
            buttons: [
              text: 'Done'
            ]
        $ionicLoading.hide()
      , =>
        ngToast.create 'For some reason, that didn\'t work.'
        $ionicLoading.hide()

  resource
]

module.exports = LinkInvitation
