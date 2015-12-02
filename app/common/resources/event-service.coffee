Event = ['$http', '$filter', '$meteor', '$q', '$resource',  \
         'apiRoot', 'User', \
         ($http, $filter, $meteor, $q, $resource, apiRoot, \
          User) ->
  listUrl = "#{apiRoot}/events"
  detailUrl = "#{listUrl}/:id"
  serializeEvent = (event) ->
    request =
      creator: event.creatorId
      title: event.title
    optionalFields =
      id: 'id'
    for serializedField, deserializedField of optionalFields
      if angular.isDefined event[deserializedField]
        request[serializedField] = event[deserializedField]
    if angular.isObject event.place
      request.place =
        name: event.place?.name
        geo:
          type: 'Point'
          coordinates: [event.place?.lat, event.place?.long]
    if angular.isDate event.datetime
      request.datetime = event.datetime.toISOString()
    if angular.isDefined event.friendsOnly
      request.friends_only = event.friendsOnly
    request
  deserializeEvent = (event) ->
    response =
      id: event.id
      creatorId: event.creator
      title: event.title
      friendsOnly: event.friends_only
      createdAt: new Date event.created_at
      updatedAt: new Date event.updated_at
    if angular.isString event.datetime
      response.datetime = new Date event.datetime
    if angular.isObject event.place
      response.place =
        name: event.place.name
        lat: event.place.geo.coordinates[0]
        long: event.place.geo.coordinates[1]
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
