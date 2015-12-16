class Event
  @$inject: ['$ionicModal', '$stateParams', '$rootScope', '$scope', \
             'Auth', 'User']
  constructor: (@$ionicModal, @$stateParams, @$rootScope, @$scope,
                @Auth, @User) ->
    # State params
    #   if not set, ui.router defaults to null
    #   default to undefined instead
    @savedEvent = @$stateParams.savedEvent
    @commentsCount = @$stateParams.commentsCount
    @recommendedEvent = @$stateParams.recommendedEvent

    # Init variables
    @contacts = {}

    @$scope.$on '$ionicView.enter', =>
      @setupSearchModal()
      @items = @buildItems()

  setupSearchModal: =>
    # Init search modal
    modalOptions =
      scope: @$scope
      animation: 'slide-in-up'
      focusFirstInput: true
    modalTemplate = """
      <ion-modal-view id="invite-friends-modal">
        <ion-header-bar>
          <button class="button button-icon icon"
                  ng-click="event.hideSearchModal()">
            <i class="fa fa-close"></i>
          </button>
          <h1 class="title">See Who's Down</h1>
        </ion-header-bar>
        <ion-content scroll="false">
          <div class="search-bar">
            <i class="fa fa-search"></i>
            <input id="enter-place"
                   ng-model="searchQuery"
                   placeholder="Search">
          </div>
          <div id="invite-friends">
            <div id="section-header" ng-if="!searchQuery">
              <p>We'll send them a text with your message and a link to reply if they're not on Rallytap.</p>
            </div>
            <ion-item ng-repeat="item in event.items | filter:searchQuery | limitTo:20"
                  class="item-avatar item-icon-right friend"
                  item-height="52px"
                  item-width="100%">
              <!-- User -->
              <div>
                <img class="item-image"
                     ng-if="item.user.imageUrl"
                     ng-src="{{item.user.getImageUrl()}}">
                <span class="contact-image item-image"
                      ng-if="!item.user.imageUrl">
                      {{item.user.getInitials()}}
                </span>
                <h2>{{item.user.name}}</h2>
                <invite-button ng-if="item.user.id"
                               user="item.user"
                               recommended-event="event.recommendedEvent"
                               event="event.savedEvent.event">
              </div>
            </ion-item>
          </div>
        </ion-content>
      </ion-modal-view>
    """
    @searchModal = @$ionicModal.fromTemplate modalTemplate, modalOptions

    # Clean up the search modal
    @$scope.$on '$destroy', =>
      @searchModal.remove()

  hideSearchModal: =>
    @searchModal.hide()

  buildItems: =>
    items = []
    usersMap = {} # to remove duplicates

    # Friends
    for userId, user of @Auth.user.friends
      items.push
        user: user
      usersMap[user.id] = true

    # Facebook friends
    for userId, user of @Auth.user.facebookFriends
      if usersMap[user.id] is undefined
        items.push
          user: user
        usersMap[user.id] = true

    # Contacts
    for userId, user of @Auth.contacts
      if usersMap[user.id] is undefined
        items.push
          user: user
        usersMap[user.id] = true

    items

  showSearchModal: ->
    @searchModal.show()

  didUserSaveEvent: ->
    if @savedEvent
      angular.isArray @savedEvent.interestedFriends
    else
      angular.isDefined @recommendedEvent.wasSaved




module.exports = Event
