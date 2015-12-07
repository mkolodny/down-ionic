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
    event =
      id: 1
      title: 'Hoe down'
    ctrl = $controller InviteButtonCtrl
    ctrl.user = user
    ctrl.event = event
  )

  ##hasSentInvite
  describe 'checking is a user has sent an invite', ->
    selector = null

    beforeEach ->
      chatId = Friendship.getChatId user.id
      selector =
        chatId: chatId
        type: 'invite_action'
        'creator.id': "#{Auth.user.id}"
        'meta.event.id': event.id

    describe 'when a user has sent an invite', ->

      beforeEach ->
        ctrl.Messages =
          findOne: jasmine.createSpy('Messages.findOne').and.returnValue {}

      it 'should return true', ->
        expect(ctrl.hasSentInvite()).toBe true

    describe 'when a user has not sent an invite', ->

      beforeEach ->
        ctrl.Messages =
          findOne: jasmine.createSpy('Messages.findOne').and.returnValue undefined

      it 'should return false', ->
        expect(ctrl.hasSentInvite()).toBe false


  ##hasBeenInvited
  describe 'checking is a user has been invited', ->
    selector = null

    beforeEach ->
      chatId = Friendship.getChatId user.id
      selector =
        chatId: chatId
        type: 'invite_action'
        'meta.event.id': event.id
        'creator.id':
          $ne: "#{Auth.user.id}"

    describe 'when a user has been invited', ->

      beforeEach ->
        ctrl.Messages =
          findOne: jasmine.createSpy('Messages.findOne').and.returnValue {}

      it 'should return true', ->
        expect(ctrl.hasSentInvite()).toBe true

    describe 'when a user has not been invited', ->

      beforeEach ->
        ctrl.Messages =
          findOne: jasmine.createSpy('Messages.findOne').and.returnValue undefined

      it 'should return false', ->
        expect(ctrl.hasSentInvite()).toBe false


  ##inviteUser
  describe 'inviting a user', ->

    describe 'when this is the user\'s first time', ->

      beforeEach ->
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

      beforeEach ->
        Auth.flags =
          hasSentInvite: true
        deferred = $q.defer()
        $meteor.call.and.returnValue deferred.promise

        ctrl.inviteUser()

      it 'should set the loading flag', ->
        expect(ctrl.isLoading).toBe true

      it 'should call the send invite meteor method', ->
        creator =
          id: "#{Auth.user.id}"
          name: Auth.user.name
          firstName: Auth.user.firstName
          lastName: Auth.user.lastName
          imageUrl: Auth.user.imageUrl
        expect($meteor.call).toHaveBeenCalledWith('sendEventInvite', creator,
            "#{user.id}", event)

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
      spyOn $mixpanel, 'track'
      Auth.isFriend.and.returnValue true

      ctrl.trackInvite()

    it 'should track inviting a friend in mixpanel', ->
      expect($mixpanel.track).toHaveBeenCalledWith 'Send Invite',
        'is friend': true
        'from screen': $state.current.name


  ##showSentInvitePopup
  describe 'showing the sent invite popup', ->
    popupOptions = null

    beforeEach ->
      spyOn($ionicPopup, 'show').and.callFake (options) ->
        popupOptions = options

      ctrl.showSentInvitePopup()

    fit 'should show an ionic popup', ->
      expect($ionicPopup.show).toHaveBeenCalledWith
        title: 'Send Message?'
        subTitle: "Tapping \"Down?\" sends #{user.name} a message asking if they\'re down for \"#{event.title}\""
        buttons: [
          text: 'Cancel'
        ,
          text: '<b>Send</b>'
          onTap: jasmine.any Function
        ]
