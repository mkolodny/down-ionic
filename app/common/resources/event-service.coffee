Event = ['$http', '$filter', '$meteor', '$q', '$resource',  \
         'apiRoot', 'Friendship', 'User', \
         ($http, $filter, $meteor, $q, $resource, apiRoot, \
          Friendship, User) ->
  listUrl = "#{apiRoot}/events"
  detailUrl = "#{listUrl}/:id"
  serializeEvent = (event) ->
    request =
      creator: event.creatorId
      title: event.title
    optionalFields =
      id: 'id'
      invitations: 'invitations'
    for serializedField, deserializedField of optionalFields
      if event[deserializedField]?
        request[serializedField] = event[deserializedField]
    if event.place?
      request.place =
        name: event.place?.name
        geo:
          type: 'Point'
          coordinates: [event.place?.lat, event.place?.long]
    if event.datetime?
      request.datetime = event.datetime.toISOString()
    if event.minAccepted?
      request.min_accepted = event.minAccepted
    request
  deserializeEvent = (event) ->
    response =
      id: event.id
      creatorId: event.creator
      title: event.title
      createdAt: new Date event.created_at
      updatedAt: new Date event.updated_at
    if event.datetime?
      response.datetime = new Date event.datetime
    if event.place?
      response.place =
        name: event.place.name
        lat: event.place.geo.coordinates[0]
        long: event.place.geo.coordinates[1]
    if event.comment?
      response.comment = event.comment
    if event.min_accepted?
      response.minAccepted = event.min_accepted
    new resource response

  resource = $resource detailUrl

  resource.listUrl = listUrl

  resource.serialize = serializeEvent
  resource.deserialize = deserializeEvent

  resource.save = (event) ->
    deferred = $q.defer()

    data = serializeEvent event
    $http.post listUrl, data
      .success (data, status) =>
        event = deserializeEvent data
        deferred.resolve event
      .error (data, status) =>
        deferred.reject()

    {$promise: deferred.promise}

  resource.getInvitedIds = (event) ->
    deferred = $q.defer()

    $http.get "#{listUrl}/#{event.id}/invited-ids"
      .success (data, status) ->
        deferred.resolve data
      .error (data, status) ->
        deferred.reject()

    deferred.promise

  resource::getPercentRemaining = ->
    currentDate = new Date()
    twentyFourHrsAgo = angular.copy currentDate
    twentyFourHrsAgo.setDate currentDate.getDate()-1
    oneDay = currentDate - twentyFourHrsAgo

    if @datetime?
      oneDayAfterEvent = @datetime.getTime() + oneDay
      eventDuration = oneDayAfterEvent - @createdAt.getTime()
      timeRemaining = oneDayAfterEvent - currentDate.getTime()
    else
      eventDuration = oneDay
      timeRemaining = @createdAt - twentyFourHrsAgo

    (timeRemaining / eventDuration) * 100

  resource::getEventMessage = ->
    if angular.isDefined @datetime
      date = $filter('date') @datetime, "EEE, MMM d 'at' h:mm a"
      dateString = " — #{date}"
    else
      dateString = ''

    if angular.isDefined @place
      placeString = " at #{@place.name}"
    else
      placeString = ''

    "#{@title}#{placeString}#{dateString}"

  resource
]

module.exports = Event
