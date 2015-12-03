class TabsCtrl
  @$inject: ['Messages']
  constructor: (@Messages) ->
    # NOTE: @Messages.unreadCount being accessing in the html

module.exports = TabsCtrl
