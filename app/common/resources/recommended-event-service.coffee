RecommendedEvent = ['$resource', 'apiRoot', ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/recommended-events"

  # serializeRecommendedEvent = (recommendedEvent) ->
    # Not needed because client can't save recommended events

  deserializeRecommendedEvent = (data) ->
    response =
      id: data.id
      title: data.title
    if data.datetime?
      response.datetime = new Date data.datetime
    if data.place?
      response.place =
        name: data.place.name
        lat: data.place.geo.coordinates[0]
        long: data.place.geo.coordinates[1]

    new resource response

  resource = $resource "#{listUrl}/:id", null,
    query:
      method: 'get'
      isArray: true
      transformResponse: (data, headersGetter) ->
        data = angular.fromJson data
        (deserializeRecommendedEvent(recommendedEvent) for recommendedEvent in data)

  resource.listUrl = listUrl

  # resource.serialize = serializeRecommendedEvent
  resource.deserialize = deserializeRecommendedEvent

  resource
]

module.exports = RecommendedEvent
