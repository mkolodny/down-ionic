require 'angular'
require 'angular-mocks'
require 'angular-ui-router'
require '../auth/auth-module'
require '../mixpanel/mixpanel-module'
require '../meteor/meteor-mocks'
require './select-friend-button-module'

fdescribe 'select friend button directive', ->
  $compile = null
  $q = null
  $state = null
  $rootScope = null
  $meteor = null
  $mixpanel = null
  Auth = null
  deferred = null
  element = null
  FriendSelects = null
  Friendship = null
  friend = null
  scope = null
  User = null

  beforeEach angular.mock.module('analytics.mixpanel')

  beforeEach angular.mock.module('rallytap.selectFriendButton')

  beforeEach angular.mock.module('angular-meteor')

  # beforeEach angular.mock.module(($provide) ->
  #   # Mock a logged in user.
  #   Auth =
  #     user:
  #       id: 1
  #     setUser: jasmine.createSpy 'Auth.setUser'
  #   $provide.value 'Auth', Auth
  #   return
  # )

  beforeEach inject(($injector) ->
    $compile = $injector.get '$compile'
    $rootScope = $injector.get '$rootScope'
    scope = $rootScope.$new()
    $state = $injector.get '$state'
    $meteor = $injector.get '$meteor'
    $mixpanel = $injector.get '$mixpanel'
    $q = $injector.get '$q'

    FriendSelects = 
      findOne: jasmine.createSpy 'FriendSelects.findOne'
    $meteor.getCollectionByName.and.returnValue FriendSelects

    friend =
      id: 2
    scope.friend = friend
    element = angular.element """
      <select-friend-button user="friend">
      """
  )

  describe 'when the friend is selected', ->

    describe 'when there is friend select data', ->
      isolatedScope = null

      afterEach ->
        jasmine.clock().uninstall()

      beforeEach ->
        jasmine.clock().install()
        date = new Date 1
        jasmine.clock().mockDate date
        threeHours = 1000 * 60 * 60 * 3
        threeHoursFromNow = new Date(date.getTime() + threeHours)
        friendSelect = 
          userId: 1
          friendId: 2
          expiresAt: threeHoursFromNow
        FriendSelects.findOne.and.returnValue friendSelect

        $compile(element) scope
        isolatedScope = element.isolateScope()
        isolatedScope.tempPercentRemaing = 75
        scope.$digest()

      it 'should show the canvas timer', ->
        timer = element.find 'canvas'
        expect(timer.length).toEqual 1

      it 'should disable selecting', ->
        anchor = element.find 'a'
        expect(anchor).toHaveProp 'disabled'

      it 'should show the percent remaining', ->
        percentRemaining = isolatedScope.percentRemaining(friend)
        expect(percentRemaining).toEqual 50

      it 'should clear tempPercentRemaing', ->
        expect(isolatedScope.tempPercentRemaing).toEqual undefined


    describe 'when using the temp percent remaining', ->
      isolatedScope = null

      beforeEach ->
        FriendSelects.findOne.and.returnValue undefined

        $compile(element) scope
        isolatedScope = element.isolateScope()
        isolatedScope.tempPercentRemaing = 75
        scope.$digest()

      it 'should show the canvas timer', ->
        timer = element.find 'canvas'
        expect(timer.length).toEqual 1

      it 'should disable selecting', ->
        anchor = element.find 'a'
        expect(anchor).toHaveProp 'disabled'

      it 'should show the percent remaining', ->
        percentRemaining = isolatedScope.percentRemaining friend
        expect(percentRemaining).toEqual 75


  describe 'when the friend is not selected', ->

    beforeEach ->
      FriendSelects.findOne.and.returnValue undefined

      $compile(element) scope
      scope.$digest()

    it 'should hide the canvas timer', ->
      timer = element.find 'canvas'
      expect(timer.length).toEqual 0

    describe 'selecting a friend', ->
      deferred = null

      beforeEach ->
        deferred = $q.defer()
        $meteor.call.and.returnValue deferred.promise

        anchor = element.find 'a'
        anchor.triggerHandler 'click'

      it 'should call the select friend Meteor method', ->
        expect($meteor.call).toHaveBeenCalledWith 'selectFriend', "#{friend.id}"

      it 'should show a loading spinner', ->
        spinner = element.find 'ion-spinner'
        expect(spinner.length).toEqual 1

      describe 'when the method returns successfully', ->

        describe 'when is is a match', ->

          beforeEach ->
            spyOn $rootScope, '$broadcast'
            deferred.resolve true
            scope.$apply()

          it 'should hide the loading spinner', ->
            spinner = element.find 'ion-spinner'
            expect(spinner.length).toEqual 0

          it 'should broadcast a new match event', ->
            expect($rootScope.$broadcast).toHaveBeenCalledWith 'rallytap.newMatch', friend


        describe 'when it is not a match', ->

          beforeEach ->
            deferred.resolve false
            scope.$apply()

          it 'should set percent remaining to 100', ->
            isolatedScope = element.isolateScope()
            percentRemaining = isolatedScope.percentRemaining friend
            expect(percentRemaining).toEqual 100


      describe 'when there is an error', ->

        beforeEach ->
          deferred.reject()
          scope.$apply()

        it 'should hide the loading spinner', ->
          spinner = element.find 'ion-spinner'
          expect(spinner.length).toEqual 0