Event = ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/events"
  detailUrl = "#{listUrl}/:id"

  $resource "#{listUrl}/:id", null,
    save:
      method: 'post'
      transformRequest: (data, headersGetter) ->
        request =
          title: data.title
          creator: data.creatorId
          canceled: data.canceled
          datetime: data.datetime.getTime()
          createdAt: data.createdAt.getTime()
          updatedAt: data.updatedAt.getTime()
          place:
            name: data.place.name
            geo: "POINT(#{data.place.lat} #{data.place.long})"
        angular.toJson request
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        coords = data.place.geo.coordinates
        response =
          id: data.id
          title: data.title
          creatorId: data.creator
          canceled: data.canceled
          datetime: new Date(data.datetime)
          createdAt: new Date(data.createdAt)
          updatedAt: new Date(data.updatedAt)
          place:
            name: data.place.name
            lat: coords[0]
            long: coords[1]
        response

    sendMessage:
      method: 'post'
      url: "#{detailUrl}/messages"
      params: {id: '@eventId'}
      transformRequest: (data, headersGetter) ->
        delete data.eventId
        angular.toJson data

    cancel:
      method: 'delete'
      url: detailUrl

module.exports = Event
