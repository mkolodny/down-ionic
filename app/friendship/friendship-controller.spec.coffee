require 'angular'
require 'angular-mocks'
require '../common/auth/auth-module'
require '../common/mixpanel/mixpanel-module'
FriendshipCtrl = require './friendship-controller'

describe 'friendship controller', ->
  $mixpanel = null
  Auth = null
  ctrl = null
  friend = null
  Friendship = null
  Invitation = null
  scope = null
  User = null

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.auth')

  beforeEach inject(($injector) ->
    $controller = $injector.get '$controller'
    $mixpanel = $injector.get '$mixpanel'
    $stateParams = angular.copy $injector.get('$stateParams')
    Auth = angular.copy $injector.get('Auth')
    Invitation = $injector.get 'Invitation'
    Friendship = $injector.get 'Friendship'
    scope = $injector.get '$rootScope'
    User = $injector.get 'User'

    friend =
      id: 1
      email: 'benihana@gmail.com'
      name: 'Benny Hana'
      username: 'benihana'
      imageUrl: 'https://facebook.com/profile-pics/benihana'
      location:
        lat: 40.7265834
        long: -73.9821535
    $stateParams.friend = friend

    ctrl = $controller FriendshipCtrl,
      $scope: scope
      $stateParams: $stateParams
      Auth: Auth
  )

  it 'should set the friend on the controller', ->
    expect(ctrl.friend).toBe friend

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
        groupId: '1,2'
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
        groupId: '1,2'
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
      spyOn Friendship, 'sendMessage'
      spyOn $mixpanel, 'track'

      ctrl.sendMessage()

    it 'should send the message', ->
      expect(Friendship.sendMessage).toHaveBeenCalledWith ctrl.friend, message

    it 'should track Sent message in Mixpanel', ->
      expect($mixpanel.track).toHaveBeenCalledWith 'Send Message',
        to: 'friend'

    it 'should clear the message', ->
      expect(ctrl.message).toBeNull()
