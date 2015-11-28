class EventsCtrl
  @$inject: ['$meteor', '$scope', '$stateParams', 'Auth']
  constructor: (@$meteor, @$scope, @$stateParams, @Auth) ->
    @event = @$stateParams.event
    @Comments = @$meteor.getCollectionByName 'comments'

    @$scope.$on '$ionicView.beforeEnter', =>
      @$scope.$meteorSubscribe 'comments', "#{@event.id}"
      @comments = @$scope.$meteorCollection @getComments, false

  getComments: ->
    selector =
      eventId: "#{@event.id}"
    options =
      sort:
        createdAt: -1
    @Comments.find selector, options

  postComment: ->
    @Comments.insert
      creator:
        id: "#{@Auth.user.id}"
        name: @Auth.user.name
        firstName: @Auth.user.firstName
        lastName: @Auth.user.lastName
        imageUrl: @Auth.user.imageUrl
      eventId: "#{@event.id}"
      createdAt: new Date()
      text: @newComment

    @newComment = null

module.exports = EventsCtrl
