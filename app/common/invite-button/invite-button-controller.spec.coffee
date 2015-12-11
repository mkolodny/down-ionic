require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../auth/auth-module'
require '../mixpanel/mixpanel-module'
require '../meteor/meteor-mocks'
require '../resources/resources-module'
InviteButtonCtrl = require './invite-button-controller'

describe 'invite button directive', ->
  $ionicPopup = null
  $q = null
  $state = null
  $meteor = null
  $mixpanel = null
  Auth = null
  ctrl = null
  deferred = null
  element = null
  event = null
  user = null
  Friendship = null
  isolateScope = null
  Messages = null
  scope = null
  User = null
  ngToast = null

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('ionic')

  beforeEach angular.mock.module('ngToast')

  beforeEach angular.mock.module(($provide) ->
    # Mock a logged in user.
    Auth =
      user:
        id: 1
        name: 'Andrew Linfoot'
        firstName: 'Andrew'
        lastName: 'Linfoot'
        imageUrl: 'http://worldssexiestmen.com/alinfoot'
      isFriend: jasmine.createSpy 'Auth.isFriend'
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $ionicPopup = $injector.get '$ionicPopup'
    scope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $meteor = $injector.get '$meteor'
    $mixpanel = $injector.get '$mixpanel'
    $q = $injector.get '$q'
    Friendship = $injector.get 'Friendship'
    User = $injector.get 'User'
    ngToast = $injector.get 'ngToast'

    Messages =
      findOne: jasmine.createSpy 'Messages.findOne'
    $meteor.getCollectionByName.and.returnValue Messages

    user =
      id: 2
      name: 'Billy Bob'
      firstName: 'Billy'
    event =
      id: 1
      title: 'Hoe down'
    ctrl = $controller InviteButtonCtrl
    ctrl.user = user
  )

  ##hasSentInvite
  describe 'checking is a user has sent an invite', ->
    selector = null
    chatId = null
    response = null

    beforeEach ->
      ctrl.Messages =
        findOne: jasmine.createSpy 'Messages.findOne'
      chatId = Friendship.getChatId user.id

    describe 'when there is an event', ->

      beforeEach ->
        ctrl.event = event
        selector =
          chatId: chatId
          type: 'invite_action'
          'creator.id': "#{Auth.user.id}"
          'meta.event.id': event.id

      describe 'when a user has sent an invite', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue {}
          response = ctrl.hasSentInvite()

        it 'should return true', ->
          expect(response).toBe true

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector


      describe 'when a user has not sent an invite', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue undefined
          response = ctrl.hasSentInvite()

        it 'should return false', ->
          expect(response).toBe false

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector


    describe 'when there is a recommended event', ->

      beforeEach ->
        ctrl.recommendedEvent = event
        selector =
          $or: [
            chatId: chatId
            type: 'invite_action'
            'creator.id': "#{Auth.user.id}"
            'meta.recommendedEvent.id': event.id
          ,
            chatId: chatId
            type: 'invite_action'
            'creator.id': "#{Auth.user.id}"
            'meta.event.recommendedEvent': event.id
          ]

      describe 'when a user has sent an invite', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue {}
          response = ctrl.hasSentInvite()

        it 'should return true', ->
          expect(response).toBe true

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector


      describe 'when a user has not sent an invite', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue undefined
          response = ctrl.hasSentInvite()

        it 'should return false', ->
          expect(response).toBe false

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector


  ##hasBeenInvited
  describe 'checking is a user has been invited', ->
    selector = null
    chatId = null
    response = null

    beforeEach ->
      ctrl.Messages =
        findOne: jasmine.createSpy 'Messages.findOne'
      chatId = Friendship.getChatId user.id


    describe 'when there is an event', ->

      beforeEach ->
        ctrl.event = event
        selector =
          chatId: chatId
          type: 'invite_action'
          'meta.event.id': event.id
          'creator.id':
            $ne: "#{Auth.user.id}"

      describe 'when a user has been invited', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue {}
          response = ctrl.hasBeenInvited()

        it 'should return true', ->
          expect(response).toBe true

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector

      describe 'when a user has not been invited', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue undefined
          response = ctrl.hasBeenInvited()

        it 'should return false', ->
          expect(response).toBe false

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector

    describe 'when there is a recommended event', ->

      beforeEach ->
        ctrl.recommendedEvent = event
        selector =
          $or: [
            chatId: chatId
            type: 'invite_action'
            'meta.recommendedEvent.id': event.id
            'creator.id':
              $ne: "#{Auth.user.id}"
          ,
            chatId: chatId
            type: 'invite_action'
            'meta.event.recommendedEvent': event.id
            'creator.id':
              $ne: "#{Auth.user.id}"
          ]

      describe 'when a user has been invited', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue {}
          response = ctrl.hasBeenInvited()

        it 'should return true', ->
          expect(response).toBe true

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector

      describe 'when a user has not been invited', ->

        beforeEach ->
          ctrl.Messages.findOne.and.returnValue undefined
          response = ctrl.hasBeenInvited()

        it 'should return false', ->
          expect(response).toBe false

        it 'should query for invite action messages', ->
          expect(ctrl.Messages.findOne).toHaveBeenCalledWith selector


  ##inviteUser
  describe 'inviting a user', ->

    describe 'when this is the user\'s first time', ->

      beforeEach ->
        ctrl.event = event
        Auth.flags =
          hasSentInvite: false
        Auth.setFlag = jasmine.createSpy 'Auth.setFlag'
        spyOn ctrl, 'showSentInvitePopup'

        ctrl.inviteUser()

      it 'should set a flag', ->
        expect(Auth.setFlag).toHaveBeenCalledWith 'hasSentInvite', true

      it 'should show a popup', ->
        expect(ctrl.showSentInvitePopup).toHaveBeenCalled()


    describe 'when this isn\'t the user\'s first rodeo', ->
      deferred = null
      creator = null

      beforeEach ->
        Auth.flags =
          hasSentInvite: true
        deferred = $q.defer()
        $meteor.call.and.returnValue deferred.promise

        creator =
          id: "#{Auth.user.id}"
          name: Auth.user.name
          firstName: Auth.user.firstName
          lastName: Auth.user.lastName
          imageUrl: Auth.user.imageUrl

      describe 'when there is an event', ->

        beforeEach ->
          ctrl.event = event
          ctrl.inviteUser()

        it 'should call the send invite meteor method', ->
          expect($meteor.call).toHaveBeenCalledWith('sendEventInvite', creator,
              "#{user.id}", event)

        it 'should set the loading flag', ->
          expect(ctrl.isLoading).toBe true

        describe 'when successful', ->

          beforeEach ->
            spyOn ctrl, 'trackInvite'

            deferred.resolve()
            scope.$apply()

          it 'should track the invite', ->
            expect(ctrl.trackInvite).toHaveBeenCalled()

          it 'should stop the loading spinner', ->
            expect(ctrl.isLoading).toBe false


        describe 'on error', ->

          beforeEach ->
            spyOn ngToast, 'create'

            deferred.reject()
            scope.$apply()

          it 'should throw an error', ->
            expect(ngToast.create).toHaveBeenCalled()

          it 'should stop the loading spinner', ->
            expect(ctrl.isLoading).toBe false


      describe 'when there is a recommended event', ->

        beforeEach ->
          ctrl.recommendedEvent = event
          ctrl.inviteUser()

        it 'should call the send recommended event invite meteor method', ->
          expect($meteor.call).toHaveBeenCalledWith('sendRecommendedEventInvite', creator,
              "#{user.id}", event)

        it 'should set the loading flag', ->
          expect(ctrl.isLoading).toBe true

        describe 'when successful', ->

          beforeEach ->
            spyOn ctrl, 'trackInvite'

            deferred.resolve()
            scope.$apply()

          it 'should track the invite', ->
            expect(ctrl.trackInvite).toHaveBeenCalled()

          it 'should stop the loading spinner', ->
            expect(ctrl.isLoading).toBe false


        describe 'on error', ->

          beforeEach ->
            spyOn ngToast, 'create'

            deferred.reject()
            scope.$apply()

          it 'should throw an error', ->
            expect(ngToast.create).toHaveBeenCalled()

          it 'should stop the loading spinner', ->
            expect(ctrl.isLoading).toBe false


  ##trackInvite
  describe 'tracking invites in mixpanel', ->

    beforeEach ->
      ctrl.event = event
      spyOn $mixpanel, 'track'
      Auth.isFriend.and.returnValue true

      ctrl.trackInvite()

    it 'should track inviting a friend in mixpanel', ->
      expect($mixpanel.track).toHaveBeenCalledWith 'Send Invite',
        'is friend': true
        'from screen': $state.current.name
        'from recommended': angular.isDefined ctrl.recommendedEvent


  ##showSentInvitePopup
  describe 'showing the sent invite popup', ->
    popupOptions = null

    beforeEach ->
      ctrl.event = event
      spyOn($ionicPopup, 'show').and.callFake (options) ->
        popupOptions = options

      ctrl.showSentInvitePopup()

    it 'should show an ionic popup', ->
      expect($ionicPopup.show).toHaveBeenCalledWith
        title: 'Send Message?'
        subTitle: "Tapping \"Down?\" sends #{user.firstName} the message \"Are you down for \"#{event.title}\"?\""
        buttons: [
          text: 'Cancel'
        ,
          text: '<b>Send</b>'
          onTap: jasmine.any Function
        ]
