SavedEvent = ['$resource', 'apiRoot', 'Event', 'User', \
              ($resource, apiRoot, Event, User) ->
  listUrl = "#{apiRoot}/saved-events"

  serializeSavedEvent = (savedEvent) ->
    request =
      user: savedEvent.userId
      event: savedEvent.eventId

    optionalFields =
      id: 'id'

    for serializedField, deserializedField of optionalFields
      if savedEvent[deserializedField]?
        request[serializedField] = savedEvent[deserializedField]

    request

  deserializeSavedEvent = (response) ->
    savedEvent =
      id: response.id

    # Always set a `<relation>Id` attribute on the savedEvent. If the relation is
    # an object, also set the relation on the savedEvent.
    if angular.isNumber response.event
      savedEvent.eventId = response.event
    else
      savedEvent.event = Event.deserialize response.event
      savedEvent.eventId = savedEvent.event.id

    if angular.isNumber response.user
      savedEvent.userId = response.user
    else
      savedEvent.user = User.deserialize response.user
      savedEvent.userId = savedEvent.user.id

    if angular.isString response.created_at
      savedEvent.createdAt = new Date response.created_at

    # Optional fields
    if angular.isArray response.interested_friends
      savedEvent.interestedFriends = (User.deserialize(friend) \
          for friend in response.interested_friends)

    if angular.isDefined response.total_num_interested
      savedEvent.totalNumInterested = response.total_num_interested

    new resource savedEvent

  resource = $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request = serializeSavedEvent data
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        deserializeSavedEvent data

    query:
      method: 'get'
      isArray: true
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        (deserializeSavedEvent(savedEvent) for savedEvent in data)

  resource.listUrl = listUrl

  resource.serialize = serializeSavedEvent
  resource.deserialize = deserializeSavedEvent

  resource::getCellHeight = ->
    ionItem = 33 # 16 top, 16 bottom, 1 borderbottom
    event = 8 # 4 top, 4 bottom
    datePosted = 18
    eventLinks = 23
    interestedFriends =
      padding: 20
      title: 26
      firstFriend: 40
      otherFriends: 51
    title = @event.getTitleHeight()

    total = title + datePosted + ionItem + event
    if angular.isDefined @interestedFriends
      total += eventLinks
      if @interestedFriends.length > 0
        total += interestedFriends.padding + interestedFriends.title + interestedFriends.firstFriend
        total += (@interestedFriends.length - 1) * interestedFriends.otherFriends

    total

  resource
]

module.exports = SavedEvent
