class CommentsCtrl
  @$inject: ['$meteor', '$mixpanel', '$scope', '$stateParams', 'Auth', 'User']
  constructor: (@$meteor, @$mixpanel, @$scope, @$stateParams, @Auth, @User) ->
    @event = @$stateParams.event
    @Comments = @$meteor.getCollectionByName 'comments'

    @$scope.$on '$ionicView.beforeEnter', =>
      @$scope.$meteorSubscribe 'comments', "#{@event.id}"
        .then =>
          @commentsLoaded = true
      @comments = @$scope.$meteorCollection @getComments, false

  getComments: =>
    selector =
      eventId: "#{@event.id}"
    options =
      sort:
        createdAt: 1
      transform: @transformComment
    @Comments.find selector, options

  postComment: ->
    @$mixpanel.track 'Post Comment',
      'comments count': @comments.length

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

  transformComment: (comment) =>
    comment.creator = new @User comment.creator
    comment


module.exports = CommentsCtrl
