RecommendedEvent = ['$resource', 'apiRoot', ($resource, apiRoot) ->
  listUrl = "#{apiRoot}/recommended-events"

  serializeRecommendedEvent = (recommendedEvent) ->

  deserializeRecommendedEvent = (data) ->

  resource = $resource "#{listUrl}/:id", null,
    save: {}

  resource.listUrl = listUrl

  resource.serialize = serializeRecommendedEvent
  resource.deserialize = deserializeRecommendedEvent

  resource
]

module.exports = RecommendedEvent
