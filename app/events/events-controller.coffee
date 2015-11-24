class EventsCtrl
  @$inject: ['$meteor', 'SavedEvent', 'RecommendedEvent']
  constructor: (@$meteor, @SavedEvent, @RecommendedEvent) ->
    @Comments = @$meteor.getCollectionByName 'comments'

  getCommentsCount: (event) ->
     


module.exports = EventsCtrl
