class Event
  @$inject: ['$ionicModal', '$stateParams', '$rootScope', '$scope', 'Auth', 'LocalDB']
  constructor: (@$ionicModal, @$stateParams, @$rootScope, @$scope, @Auth, @LocalDB) ->
    # State params
    #   if not set, ui.router defaults to null
    #   default to undefined instead
    @savedEvent = @$stateParams.savedEvent
    @commentsCount = @$stateParams.commentsCount
    @recommendedEvent = @$stateParams.recommendedEvent

    # Init variables
    @contacts = {}

    @$scope.$on '$ionicView.loaded', =>
      @setupSearchModal()

      # Set contacts on controller
      @LocalDB.get 'contacts'
        .then (contacts) =>
          if contacts isnt null
            @contacts = contacts
          @items = @buildItems()

    @$scope.$on '$ionicView.beforeEnter', =>
      @$rootScope.hideTabBar = true

  setupSearchModal: =>
    # Init search modal
    modalOptions =
      scope: @$scope
      animation: 'slide-in-up'
      focusFirstInput: true
    modalTemplate = """
      <ion-modal-view id="search">
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
                   placeholder="Search"
                   autofocus>
          </div>
          <div id="see-whos-down">
            <div id="section-header" ng-if="!searchQuery">
              <p>We'll send them a text with your message and a link to reply if they're not on Rallytap.</p>
            </div>
            <ion-item ng-repeat="item in event.items | filter:searchQuery"
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

    pushItem = (user) =>
      if usersMap[user.id] is undefined
        items.push
          user: user
        usersMap[user.id] = true

    # Friends
    for userId, user of @Auth.user.friends
      pushItem user

    # Facebook friends
    for userId, user of @Auth.user.facebookFriends
      pushItem user

    # Contacts
    for userId, user of @contacts
      pushItem user

    items

  showSearchModal: ->
    @searchModal.show()




module.exports = Event
