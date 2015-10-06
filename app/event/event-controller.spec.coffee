require '../ionic/ionic.js'
require 'angular'
require 'angular-animate'
require 'angular-mocks'
require 'angular-sanitize'
require 'angular-ui-router'
require 'ng-toast'
require '../ionic/ionic-angular.js'
require '../common/auth/auth-module'
require '../common/mixpanel/mixpanel-module'
require '../common/resources/resources-module'
require '../common/meteor/meteor-mocks'
EventCtrl = require './event-controller'

describe 'event controller', ->
  $ionicActionSheet = null
  $ionicHistory = null
  $ionicLoading = null
  $ionicModal = null
  $ionicPopup = null
  $ionicScrollDelegate = null
  $meteor = null
  $mixpanel = null
  $q = null
  $rootScope = null
  $state = null
  $timeout = null
  Auth = null
  ctrl = null
  currentDate = null
  deferredTemplate = null
  Event = null
  event = null
  chatsCollection = null
  invitation = null
  Invitation = null
  LinkInvitation = null
  messagesCollection = null
  ngToast = null
  scope = null
  User = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('ui.router')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module('ngToast')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicActionSheet = $injector.get '$ionicActionSheet'
    $ionicHistory = $injector.get '$ionicHistory'
    $ionicLoading = $injector.get '$ionicLoading'
    $ionicModal = $injector.get '$ionicModal'
    $ionicPopup = $injector.get '$ionicPopup'
    $ionicScrollDelegate = $injector.get '$ionicScrollDelegate'
    $mixpanel = $injector.get '$mixpanel'
    $meteor = $injector.get '$meteor'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $stateParams = angular.copy $injector.get('$stateParams')
    $timeout = $injector.get '$timeout'
    Auth = angular.copy $injector.get('Auth')
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'
    LinkInvitation = $injector.get 'LinkInvitation'
    ngToast = $injector.get 'ngToast'
    scope = $injector.get '$rootScope'
    User = $injector.get 'User'

    # Mock the current event.
    event =
      id: 1
      title: 'bars?!?!!?'
      creator: 2
      canceled: false
      datetime: new Date()
      createdAt: new Date()
      updatedAt: new Date()
      place:
        name: 'B Bar & Grill'
        lat: 40.7270718
        long: -73.9919324
    invitation =
      id: 1
      event: event
      fromUser: 2
      toUser:
        id: 3
        email: 'aturing@gmail.com'
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pics/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535
      response: Invitation.Accepted
      muted: false
      createdAt: new Date()
      updatedAt: new Date()
    $stateParams.invitation = invitation

    # Mock the current user.
    Auth.user = new User
      id: 3
      email: 'aturing@gmail.com'
      name: 'Alan Turing'
      username: 'tdog'
      imageUrl: 'https://facebook.com/profile-pics/tdog'
      location:
        lat: 40.7265834
        long: -73.9821535

    deferredTemplate = $q.defer()
    spyOn($ionicModal, 'fromTemplateUrl').and.returnValue deferredTemplate.promise

    messagesCollection = 'messagesCollection'
    chatsCollection = 'chatsCollection'
    $meteor.getCollectionByName.and.callFake (collectionName) ->
      if collectionName is 'messages' then return messagesCollection
      if collectionName is 'chats' then return chatsCollection

    ctrl = $controller EventCtrl,
      $scope: scope
      $stateParams: $stateParams
      Auth: Auth
  )

  afterEach ->
    jasmine.clock().uninstall()

  it 'should set the user\'s invitation on the controller', ->
    expect(ctrl.invitation).toBe invitation

  it 'should set the event on the controller', ->
    expect(ctrl.event).toBe event

  it 'should set the event title on the event', ->
    expect(ctrl.event.titleWithLongVariableName).toBe event.title

  it 'should init a guest list modal', ->
    templateUrl = 'app/guest-list/guest-list.html'
    expect($ionicModal.fromTemplateUrl).toHaveBeenCalledWith templateUrl,
      scope: scope
      animation: 'slide-in-up'

  it 'should set the current user on the guest list', ->
    expect(scope.guestList.currentUser).toBe Auth.user

  it 'should set the messages collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'messages'
    expect(ctrl.Messages).toBe messagesCollection

  it 'should set the events collection on the controller', ->
    expect($meteor.getCollectionByName).toHaveBeenCalledWith 'chats'
    expect(ctrl.Chats).toBe chatsCollection

  describe 'once the view loads', ->
    message = null
    messages = null
    chat = null

    beforeEach ->
      scope.$meteorSubscribe = jasmine.createSpy '$scope.$meteorSubscribe'

      spyOn ctrl, 'updateMembers'
      spyOn ctrl, 'getMessages'
      spyOn ctrl, 'handleNewMessage'

      message =
        _id: 1
        creator: new User Auth.user
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        chatId: "#{event.id}"
        type: 'text'
      messages = [message]
      $meteor.collection.and.returnValue messages

      chat =
        members: []
      spyOn(ctrl, 'getChat').and.returnValue chat

      spyOn ctrl, 'handleChatMembersChange'

      scope.$emit '$ionicView.beforeEnter'
      scope.$apply()

    it 'should subscribe to the events messages', ->
      expect(scope.$meteorSubscribe).toHaveBeenCalledWith 'chat', "#{event.id}"

    it 'should bind the messages to the controller', ->
      # TODO: Check that controller property is set
      expect($meteor.collection).toHaveBeenCalledWith ctrl.getMessages, false

    it 'should bind the meteor event members to the controller', ->
      expect(ctrl.chat).toEqual chat
      expect(ctrl.getChat).toHaveBeenCalled()

    it 'should update the members array', ->
      expect(ctrl.updateMembers).toHaveBeenCalled()

    describe 'when a new message is posted', ->
      message2 = null

      beforeEach ->
        ctrl.handleNewMessage.calls.reset()

        # Trigger @$scope.watch
        message2 = angular.extend {}, message,
          _id: message._id+1
          type: Invitation.acceptAction
        ctrl.messages.push message2
        scope.$apply()

      it 'should handle the message', ->
        expect(ctrl.handleNewMessage).toHaveBeenCalled()

    describe 'when the chat changes', ->
      chatMembers = null

      beforeEach ->
        chatMembers = [
          userId: '1'
        ,
          userId: '2'
        ]
        ctrl.chat.members = chatMembers

        ctrl.handleChatMembersChange.calls.reset()
        scope.$apply()

      it 'should handle the change', ->
        expect(ctrl.handleChatMembersChange).toHaveBeenCalled()


  describe 'when leaving the view', ->

    beforeEach ->
      ctrl.messages =
        stop: jasmine.createSpy 'messages.stop'
      ctrl.chat =
        stop: jasmine.createSpy 'chat.stop'

      scope.$broadcast '$ionicView.leave'
      scope.$apply()

    it 'should stop remove angular-meteor bindings', ->
      expect(ctrl.messages.stop).toHaveBeenCalled()
      expect(ctrl.chat.stop).toHaveBeenCalled()

    it 'should show the bottom border', ->
      expect($rootScope.hideNavBottomBorder).toBe false


  describe 'handling a new message', ->
    newMessageId = null

    beforeEach ->
      spyOn ctrl, 'scrollBottom'
      newMessageId = '1jkhkgfjgfhftxhgdxf'

      ctrl.handleNewMessage newMessageId

    it 'should mark the message as read', ->
      expect($meteor.call).toHaveBeenCalledWith 'readMessage', newMessageId

    it 'should scroll to the bottom', ->
      expect(ctrl.scrollBottom).toHaveBeenCalled()


  describe 'getting messages', ->
    cursor = null
    result = null

    beforeEach ->
      cursor = 'messagesCursor'
      ctrl.Messages =
        find: jasmine.createSpy('Messages.find').and.returnValue cursor
      result = ctrl.getMessages()

    it 'should return a messages reactive cursor', ->
      expect(result).toBe cursor

    it 'should query, sort and transform messages', ->
      selector =
        chatId: "#{ctrl.event.id}"
      options =
        sort:
          createdAt: 1
        transform: ctrl.transformMessage
      expect(ctrl.Messages.find).toHaveBeenCalledWith selector, options


  describe 'getting the newest message', ->
    result = null
    newestMessage = null

    beforeEach ->
      newestMessage = 'newestMessage'
      $meteor.object.and.returnValue newestMessage
      result = ctrl.getNewestMessage()

    it 'should return a AngularMeteorObject', ->
      expect(result).toEqual newestMessage

    it 'should filter object by event id and sort by created at', ->
      selector =
        chatId: "#{ctrl.event.id}"
      options =
        sort:
          createdAt: -1
      expect($meteor.object).toHaveBeenCalledWith(ctrl.Messages, selector, false,
          options)


  describe 'getting meteor chat', ->
    result = null
    chat = null

    beforeEach ->
      chat = 'chat'
      $meteor.object.and.returnValue chat
      result = ctrl.getChat()

    it 'should return an AngularMeteorObject', ->
      expect(result).toEqual chat

    it 'should filter for the current event', ->
      selector =
        chatId: "#{ctrl.event.id}"
      expect($meteor.object).toHaveBeenCalledWith ctrl.Chats, selector, false


  describe 'transforming messages', ->
    message = null
    result = null

    beforeEach ->
      message =
        creator: {}
      result = ctrl.transformMessage message

    it 'should create a new User object with the message.creator', ->
      expectedResult = angular.copy message
      expectedResult.creator = new User expectedResult.creator

      expect(result).toEqual expectedResult


  describe 'handling chat members changes', ->

    describe 'when users are added or removed', ->
      member1 = null
      member2 = null

      beforeEach ->
        member1 =
          id: 1
          name: 'Jim Bob'
        member2 =
          id: 2
          name: 'The Other Guy'
        ctrl.members = [member1, member2]

        spyOn ctrl, 'updateMembers'
        ctrl.handleChatMembersChange [{userId: 1}]

      it 'should update members', ->
        expect(ctrl.updateMembers).toHaveBeenCalled()


  describe 'when the modal loads', ->
    modal = null

    beforeEach ->
      modal =
        remove: jasmine.createSpy 'modal.remove'
        hide: jasmine.createSpy 'modal.hide'
      deferredTemplate.resolve modal
      scope.$apply()

    it 'should save the modal on the controller', ->
      expect(ctrl.guestListModal).toBe modal

    describe 'then the modal is hidden', ->

      beforeEach ->
        scope.$broadcast '$destroy'
        scope.$apply()

      it 'should clean up the modal', ->
        expect(modal.remove).toHaveBeenCalled()


    describe 'hiding the guest list modal', ->

      beforeEach ->
        scope.guestList.hide()

      it 'should hide the modal', ->
        expect(modal.hide).toHaveBeenCalled()


  describe 'building the guest list', ->
    acceptedInvitation = null
    maybeInvitation = null

    beforeEach ->
      acceptedInvitation = angular.extend {}, invitation,
        response: Invitation.accepted
      maybeInvitation = angular.extend {}, invitation,
        response: Invitation.maybe
      memberInvitations = [acceptedInvitation, maybeInvitation]

      ctrl.buildGuestList memberInvitations

    it 'should set the items on the scope', ->
      items = [
        isDivider: true
        title: 'Down'
      ,
        isDivider: false
        user: acceptedInvitation.toUser
      ,
        isDivider: true
        title: 'Maybe'
      ,
        isDivider: false
        user: maybeInvitation.toUser
      ]
      for item in items
        if item.isDivider
          item.id = item.title
        else
          item.id = item.user.id
      expect(scope.guestList.items).toEqual items


  describe 'showing the guest list', ->

    beforeEach ->
      ctrl.guestListModal =
        show: jasmine.createSpy 'guestListModal.show'

      ctrl.showGuestList()

    it 'should show the guest list modal', ->
      expect(ctrl.guestListModal.show).toHaveBeenCalled()


  describe 'updating the members array', ->
    deferred = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Invitation, 'getMemberInvitations').and.returnValue
        $promise: deferred.promise

      ctrl.updateMembers()

    describe 'successfully', ->
      acceptedInvitation = null
      maybeInvitation = null
      invitations = null

      beforeEach ->
        spyOn ctrl, 'buildGuestList'

        acceptedInvitation = angular.extend {}, invitation,
          response: Invitation.accepted
        maybeInvitation = angular.extend {}, invitation,
          response: Invitation.maybe
        invitations = [acceptedInvitation, maybeInvitation]
        deferred.resolve invitations
        scope.$apply()

      it 'should set the accepted/maybe invitations on the controller', ->
        memberInvitations = [acceptedInvitation, maybeInvitation]
        members = (invitation.toUser for invitation in memberInvitations)
        expect(ctrl.members).toEqual members

      it 'should build the guest list', ->
        memberInvitations = [acceptedInvitation, maybeInvitation]
        expect(ctrl.buildGuestList).toHaveBeenCalledWith memberInvitations


    describe 'unsuccessfully', ->

      beforeEach ->
        deferred.reject()
        scope.$apply()

      it 'should show an error', ->
        # TODO: Show the error in the view.
        expect(ctrl.membersError).toBe true


  describe 'toggling whether the header is expanded', ->

    describe 'when the header is expanded', ->

      beforeEach ->
        ctrl.isHeaderExpanded = true

        ctrl.toggleIsHeaderExpanded()

      it 'should collapse the header', ->
        expect(ctrl.isHeaderExpanded).toBe false

      describe 'after a bit', ->

        beforeEach ->
          $timeout.flush 160
          scope.$apply()

        it 'should show the nav bottom border', ->
          expect($rootScope.hideNavBottomBorder).toBe false


      describe 'then it\'s collapsed', ->

        beforeEach ->
          ctrl.toggleIsHeaderExpanded()

        describe 'after a bit', ->

          beforeEach ->
            $timeout.flush 160
            scope.$apply()

          fit 'should hide the nav bottom border', ->
            expect($rootScope.hideNavBottomBorder).toBe true


    describe 'when the header is collapsed', ->

      beforeEach ->
        ctrl.isHeaderExpanded = false

        ctrl.toggleIsHeaderExpanded()

      it 'should unexpand the header', ->
        expect(ctrl.isHeaderExpanded).toBe true


  describe 'checking whether the user accepted their invitation', ->

    describe 'when they did', ->

      beforeEach ->
        invitation.response = Invitation.accepted

      it 'should return true', ->
        expect(ctrl.isAccepted()).toBe true


    describe 'when they didn\'t', ->

      beforeEach ->
        invitation.response = Invitation.maybe

      it 'should return false', ->
        expect(ctrl.isAccepted()).toBe false


  describe 'checking whether the user responded maybe their invitation', ->

    describe 'when they did', ->

      beforeEach ->
        invitation.response = Invitation.maybe

      it 'should return true', ->
        expect(ctrl.isMaybe()).toBe true


    describe 'when they didn\'t', ->

      beforeEach ->
        invitation.response = Invitation.accepted

      it 'should return false', ->
        expect(ctrl.isMaybe()).toBe false


  describe 'accepting the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.maybe
      invitation.response = response

      deferred = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise

      ctrl.acceptInvitation()

    it 'should update the invitation', ->
      expect(Invitation.updateResponse).toHaveBeenCalledWith invitation, \
          Invitation.accepted

    describe 'when the update fails', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'show an error', ->
        error = 'For some reason, that didn\'t work.'
        expect(ngToast.create).toHaveBeenCalledWith error


  describe 'responding maybe to the invitation', ->
    response = null
    deferred = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.accepted
      invitation.response = response

      deferred = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferred.promise

      ctrl.maybeInvitation()

    it 'should update the invitation', ->
      expect(Invitation.updateResponse).toHaveBeenCalledWith invitation, \
          Invitation.maybe

    describe 'when the update fails', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        scope.$apply()

      it 'show an error', ->
        error = 'For some reason, that didn\'t work.'
        expect(ngToast.create).toHaveBeenCalledWith error


  describe 'declining the invitation', ->
    response = null
    deferredUpdateResponse = null

    beforeEach ->
      # Mock the current invitation response.
      response = Invitation.accepted
      invitation.response = response

      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'
      deferredUpdateResponse = $q.defer()
      spyOn(Invitation, 'updateResponse').and.returnValue
        $promise: deferredUpdateResponse.promise

      ctrl.declineInvitation()

    it 'should show a loading overlay', ->
      expect($ionicLoading.show).toHaveBeenCalled()

    describe 'successfully', ->
      deferredCacheClear = null

      beforeEach ->
        spyOn $state, 'go'
        deferredCacheClear = $q.defer()
        spyOn $ionicHistory, 'clearCache'

        deferredUpdateResponse.resolve()
        scope.$apply()

      it 'should clear the cache', ->
        expect($ionicHistory.clearCache).toHaveBeenCalled()

      describe 'when the cache is cleared', ->

        beforeEach ->
          deferredCacheClear.resolve()
          scope.$apply()

        it 'should update the invitation', ->
          expect(Invitation.updateResponse).toHaveBeenCalledWith invitation, \
              Invitation.declined

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'should go to the events view', ->
          expect($state.go).toHaveBeenCalledWith 'events'


    describe 'unsuccessfully', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferredUpdateResponse.reject()
        scope.$apply()

      it 'show an error', ->
        error = 'For some reason, that didn\'t work.'
        expect(ngToast.create).toHaveBeenCalledWith error

      it 'should hide the loading overlay', ->
        expect($ionicLoading.hide).toHaveBeenCalled()


  describe 'checking whether a message is an action message', ->
    message = null

    beforeEach ->
      creator =
        id: 2
        name: 'Guido van Rossum'
        imageUrl: 'http://facebook.com/profile-pics/vrawesome'
      message =
        _id: 1
        creator: new User creator
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        chatId: event.id
        type: 'text'

    describe 'when it is an accept action', ->

      beforeEach ->
        message.type = Invitation.acceptAction

      it 'should return true', ->
        expect(ctrl.isActionMessage message).toBe true


    describe 'when it is an maybe action', ->

      beforeEach ->
        message.type = Invitation.maybeAction

      it 'should return true', ->
        expect(ctrl.isActionMessage message).toBe true


    describe 'when it is a decline action', ->

      beforeEach ->
        message.type = Invitation.declineAction

      it 'should return true', ->
        expect(ctrl.isActionMessage message).toBe true


    describe 'when it\'s text', ->

      beforeEach ->
        message.type = 'text'

      it 'should return false', ->
        expect(ctrl.isActionMessage message).toBe false


  describe 'checking whether a message is the current user\'s message', ->
    message = null

    beforeEach ->
      creator =
        id: 2
        name: 'Guido van Rossum'
        imageUrl: 'http://facebook.com/profile-pics/vrawesome'

      message =
        _id: 1
        creator: new User creator
        createdAt:
          $date: new Date().getTime()
        text: 'I\'m in love with a robot.'
        chatId: event.id
        type: 'text'

      Auth.user =
        id: 1
        name: 'Alan Turing'
        username: 'tdog'
        imageUrl: 'https://facebook.com/profile-pics/tdog'
        location:
          lat: 40.7265834
          long: -73.9821535

    describe 'when it is', ->

      beforeEach ->
        message.creator.id = "#{Auth.user.id}" # Meteor likes strings

      it 'should return true', ->
        expect(ctrl.isMyMessage message).toBe true


    describe 'when it isn\'t', ->

      beforeEach ->
        message.creator.id = "#{Auth.user.id + 1}" # Meteor likes strings

      it 'should return false', ->
        expect(ctrl.isMyMessage message).toBe false


  describe 'sending a message', ->
    message = null

    beforeEach ->
      message = 'this is gonna be dope!'
      ctrl.message = message
      spyOn Event, 'sendMessage'

      spyOn $mixpanel, 'track'

      ctrl.sendMessage()

    it 'should send the message', ->
      expect(Event.sendMessage).toHaveBeenCalledWith event, message

    it 'should track Sent message in Mixpanel', ->
      expect($mixpanel.track).toHaveBeenCalledWith 'Send Message',
        'chat type': 'event'

    it 'should clear the message', ->
      expect(ctrl.message).toBeNull()


  describe 'showing more options', ->
    buttonClickedCallback = null
    hideSheet = null

    beforeEach ->
      spyOn($ionicActionSheet, 'show').and.callFake (options) ->
        buttonClickedCallback = options.buttonClicked
        hideSheet = jasmine.createSpy 'hideSheet'
        hideSheet

    describe 'tapping Send To.. button', ->

      beforeEach ->
        spyOn $state, 'go'
        ctrl.showMoreOptions()
        buttonClickedCallback 0

      it 'should go to the invite friends view', ->
        stateParams =
          event: ctrl.event
        expect($state.go).toHaveBeenCalledWith 'inviteFriends', stateParams

      it 'should hide the action sheet', ->
        expect(hideSheet).toHaveBeenCalled()


    describe 'tapping the get chat link button', ->

      beforeEach ->
        spyOn ctrl, 'getLinkInvitation'
        ctrl.showMoreOptions()
        buttonClickedCallback 1

      it 'should get a link invitation', ->
        expect(ctrl.getLinkInvitation).toHaveBeenCalled()


    describe 'getting a link invitation', ->
      deferred = null

      beforeEach ->
        deferred = $q.defer()
        spyOn(LinkInvitation, 'save').and.returnValue {$promise: deferred.promise}
        spyOn $ionicLoading, 'show'
        spyOn $ionicLoading, 'hide'

        ctrl.getLinkInvitation()

      it 'should show a loading overlay', ->
        expect($ionicLoading.show).toHaveBeenCalled()

      it 'should create a link invitation', ->
        linkInvitation =
          eventId: ctrl.event.id
          fromUserId: Auth.user.id
        expect(LinkInvitation.save).toHaveBeenCalledWith linkInvitation

      describe 'successfully', ->
        linkId = null

        beforeEach ->
          spyOn $mixpanel, 'track'
          spyOn $ionicPopup, 'alert'
          linkId = 'mikepleb'
          deferred.resolve {linkId: linkId}
          scope.$apply()

        it 'should show a modal with the share link', ->
          expect($ionicPopup.alert).toHaveBeenCalled()

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'should track the event in mixpanel', ->
          expect($mixpanel.track).toHaveBeenCalledWith 'Get Link Invitation'


      describe 'on error', ->

        beforeEach ->
          spyOn ngToast, 'create'

          deferred.reject()
          scope.$apply()

        it 'should show an error', ->
          error = 'For some reason, that didn\'t work.'
          expect(ngToast.create).toHaveBeenCalledWith error

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


    describe 'when notifications are turned on', ->

      beforeEach ->
        ctrl.invitation.muted = false

        ctrl.showMoreOptions()

      it 'should show an action sheet', ->
        options =
          buttons: [
            text: 'Send To...'
          ,
            text: 'Copy Group Link'
          ,
            text: 'Mute Notifications'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function
        expect($ionicActionSheet.show).toHaveBeenCalledWith options

      describe 'tapping the mute notifications button', ->

        beforeEach ->
          spyOn ctrl, 'toggleNotifications'

          buttonClickedCallback 2

        it 'should update the event', ->
          expect(ctrl.toggleNotifications).toHaveBeenCalled()

        it 'should hide the action sheet', ->
          expect(hideSheet).toHaveBeenCalled()


    describe 'when notifications are turned off', ->

      beforeEach ->
        ctrl.invitation.muted = true

        ctrl.showMoreOptions()

      it 'should show an action sheet', ->
        options =
          buttons: [
            text: 'Send To...'
          ,
            text: 'Copy Group Link'
          ,
            text: 'Turn On Notifications'
          ]
          cancelText: 'Cancel'
          buttonClicked: jasmine.any Function
        expect($ionicActionSheet.show).toHaveBeenCalledWith options


  describe 'toggling notifications', ->
    deferred = null
    originalInvitation = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(Invitation, 'update').and.returnValue {$promise: deferred.promise}
      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'
      spyOn ngToast, 'create'

      # Save the original invitation.
      originalInvitation = angular.copy invitation

    describe 'when notifications are turned on', ->

      beforeEach ->
        ctrl.invitation.muted = true

        ctrl.toggleNotifications()

      it 'should show a loading modal', ->
        expect($ionicLoading.show).toHaveBeenCalled()

      it 'should edit the muted property', ->
        expect(ctrl.invitation.muted).toBe false

      it 'should update the invitation', ->
        originalInvitation.muted = false
        expect(Invitation.update).toHaveBeenCalledWith originalInvitation

      describe 'when the update succeeds', ->

        beforeEach ->
          deferred.resolve ctrl.invitation
          scope.$apply()

        it 'should hide the loading modal', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'show a success message', ->
          message = 'Notifications are now on.'
          expect(ngToast.create).toHaveBeenCalledWith message


      describe 'when the update fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should reset the invitation', ->
          expect(ctrl.invitation.muted).toBe true

        it 'show an error', ->
          error = 'For some reason, that didn\'t work.'
          expect(ngToast.create).toHaveBeenCalledWith error

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


    describe 'when notifications are turned off', ->

      beforeEach ->
        ctrl.invitation.muted = false

        ctrl.toggleNotifications()

      it 'should show a loading modal', ->
        expect($ionicLoading.show).toHaveBeenCalled()

      it 'should edit the muted property', ->
        expect(ctrl.invitation.muted).toBe true

      it 'should update the invitation', ->
        originalInvitation.muted = true
        expect(Invitation.update).toHaveBeenCalledWith originalInvitation

      describe 'when the update succeeds', ->

        beforeEach ->
          deferred.resolve ctrl.invitation
          scope.$apply()

        it 'should hide the loading modal', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'show a success message', ->
          message = 'Notifications are now off.'
          expect(ngToast.create).toHaveBeenCalledWith message


      describe 'when the update fails', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should reset the invitation', ->
          expect(ctrl.invitation.muted).toBe false

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()


  describe 'scrolling to the bottom', ->
    scrollHandle = null

    describe 'when scrolling bottom is enabled', ->

      beforeEach ->
        scrollHandle =
          scrollBottom: jasmine.createSpy 'scrollHandle.scrollBottom'
        spyOn($ionicScrollDelegate, '$getByHandle').and.returnValue scrollHandle

        ctrl.scrollBottom()

      it 'should scroll to the bottom', ->
        expect(scrollHandle.scrollBottom).toHaveBeenCalledWith true
