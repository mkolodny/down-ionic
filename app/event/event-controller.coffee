class Event
  @$inject: ['$stateParams']
  constructor: (@$stateParams) ->
    @savedEvent = @$stateParams.savedEvent
    @commentsCount = @$stateParams.commentsCount

module.exports = Event
