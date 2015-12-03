require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require 'ng-toast'
require '../auth/auth-module'
require '../mixpanel/mixpanel-module'
require '../meteor/meteor-mocks'
require '../resources/resources-module'
require './invite-button-module'

describe 'invite button directive', ->
  $compile = null
  $q = null
  $state = null
  $meteor = null
  $mixpanel = null
  Auth = null
  deferred = null
  element = null
  event = null
  friend = null
  Friendship = null
  isolateScope = null
  Messages = null
  scope = null
  User = null
  ngToast = null

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach angular.mock.module('rallytap.inviteButton')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('angular-meteor')

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
    $compile = $injector.get '$compile'
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

    friend =
      id: 2
    scope.friend = friend
    event =
      id: 1
    scope.event = event
    element = angular.element """
      <invite-button user="friend" event="event">
      """
  )

  describe 'when the user hasn\'t been invited yet', ->

    beforeEach ->
      Messages.findOne.and.returnValue undefined

      $compile(element) scope
      isolateScope = element.isolateScope()
      spyOn(isolateScope, 'hasBeenInvited').and.returnValue false
      scope.$apply()

    it 'should show an invite button', ->
      anchor = element.find 'a'
      expect(anchor.length).toBe 1

    describe 'inviting a user', ->
      deferred = null

      beforeEach ->
        deferred = $q.defer()
        $meteor.call.and.returnValue deferred.promise

        anchor = element.find 'a'
        anchor.triggerHandler 'mousedown'

      it 'should call the send invite meteor method', ->
        creator =
          id: "#{Auth.user.id}"
          name: Auth.user.name
          firstName: Auth.user.firstName
          lastName: Auth.user.lastName
          imageUrl: Auth.user.imageUrl
        expect($meteor.call).toHaveBeenCalledWith('sendEventInvite', creator,
            "#{friend.id}", event)

      it 'should show a loading spinner', ->
        spinner = element.find 'ion-spinner'
        expect(spinner.length).toEqual 1

      describe 'when the method returns successfully', ->

        beforeEach ->
          spyOn isolateScope, 'trackInvite'
          deferred.resolve()
          scope.$apply()

        it 'should hide the loading spinner', ->
          spinner = element.find 'ion-spinner'
          expect(spinner.length).toEqual 0

        it 'should track sending an invite in mixpanel', ->
          expect(isolateScope.trackInvite).toHaveBeenCalled()


      describe 'when there is an error', ->

        beforeEach ->
          spyOn ngToast, 'create'
          deferred.reject()
          scope.$apply()

        it 'should hide the loading spinner', ->
          spinner = element.find 'ion-spinner'
          expect(spinner.length).toEqual 0

        it 'should show an error toast', ->
          expect(ngToast.create).toHaveBeenCalledWith 'Oops, an error occurred.'


  describe 'when the user has been invited', ->

    beforeEach ->
      Messages.findOne.and.returnValue {_id: '123123asdf'}

      $compile(element) scope
      isolateScope = element.isolateScope()
      scope.$apply()

    it 'should hide the invite button', ->
      inviteButton = element.find 'anchor'
      expect(inviteButton.length).toBe 0

    it 'should show an invited button', ->
      invitedButton = element.find 'button'
      expect(invitedButton.length).toBe 1


  ##$scope.trackInvite
  describe 'tracking invites in mixpanel', ->

    beforeEach ->
      spyOn $mixpanel, 'track'
      Auth.isFriend.and.returnValue true

      $compile(element) scope
      isolateScope = element.isolateScope()
      scope.$apply()
      isolateScope.trackInvite friend

    it 'should track inviting a friend in mixpanel', ->
      expect($mixpanel.track).toHaveBeenCalledWith 'Send Invite',
        'is friend': true
        'from screen': $state.current.name
