eventItemDirective = ->
  restrict: 'E'
  scope:
    savedEvent: '='
    commentsCount: '='
  bindToController: true
  templateUrl: 'app/common/event-item/event-item.html'
  controller: 'eventItemCtrl as eventItem'

module.exports = eventItemDirective
