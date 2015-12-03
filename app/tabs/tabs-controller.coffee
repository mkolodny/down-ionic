class TabsCtrl
  @$inject: ['Messages']
  constructor: (@Messages) ->
    # NOTE: @Messages.unreadCount being used in tabs.html

module.exports = TabsCtrl
