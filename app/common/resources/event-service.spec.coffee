require 'angular'
require 'angular-mocks'
require '../auth/auth-module'
require './resources-module'

describe 'event service', ->
  $httpBackend = null
  $rootScope = null
  $q = null
  Asteroid = null
  Auth = null
  Event = null
  Invitation = null
  Messages = null
  User = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach angular.mock.module('down.auth')

  beforeEach angular.mock.module(($provide) ->
    # Mock a logged in user.
    Auth =
      user:
        id: 1
        name: 'Alan Turing'
        firstName: 'Alan'
        lastName: 'Turing'
        imageUrl: 'http://facebook.com/profile-pic/tdog'
    $provide.value 'Auth', Auth

    # Mock Asteroid.
    Messages =
      insert: jasmine.createSpy 'Messages.insert'
    Asteroid =
      getCollection: jasmine.createSpy('Asteroid.getCollection').and.returnValue \
          Messages
      call: jasmine.createSpy 'Asteroid.call'
    $provide.value 'Asteroid', Asteroid
    return
  )

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    $rootScope = $injector.get '$rootScope'
    $q = $injector.get '$q'
    apiRoot = $injector.get 'apiRoot'
    User = $injector.get 'User'
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'

    listUrl = "#{apiRoot}/events"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'should have a list url', ->
    expect(Event.listUrl).toBe listUrl

  describe 'serializing an event', ->
    event = null

    beforeEach ->
      event =
        id: 1
        creatorId: 1
        title: 'bars?!?!!?'

    describe 'with the minimum amount of data', ->

      it 'should return the serialized event', ->
        expectedEvent =
          id: event.id
          creator: event.creatorId
          title: event.title
        expect(Event.serialize event).toEqual expectedEvent


    describe 'with the max amount of data', ->
      invitations = null

      beforeEach ->
        invitations = [
          to_user: 2
        ]
        event = angular.extend event,
          datetime: new Date()
          place:
            name: 'B Bar & Grill'
            lat: 40.7270718
            long: -73.9919324
          comment: 'awwww yisssss'
          canceled: false
          createdAt: new Date()
          updatedAt: new Date()
          invitations: invitations

      it 'should return the serialized event', ->
        expectedEvent =
          id: event.id
          creator: event.creatorId
          title: event.title
          datetime: event.datetime.toISOString()
          place:
            name: event.place.name
            geo:
              type: 'Point'
              coordinates: [event.place.lat, event.place.long]
          comment: 'awwww yisssss'
          canceled: event.canceled
          invitations: invitations
        expect(Event.serialize event).toEqual expectedEvent


  describe 'deserializing an event', ->
    response = null

    describe 'with the min amount of data', ->

      beforeEach ->
        response =
          id: 1
          creator: 1
          title: 'bars?!?!!?'
          canceled: false
          created_at: new Date().toISOString()
          updated_at: new Date().toISOString()

      it 'should return the deserialized event', ->
        expectedEvent =
          id: response.id
          creatorId: response.creator
          title: response.title
          canceled: response.canceled
          createdAt: new Date response.created_at
          updatedAt: new Date response.updated_at
        expect(Event.deserialize response).toAngularEqual expectedEvent

    describe 'with the max amount of data', ->

      beforeEach ->
        response =
          id: 1
          creator: 1
          title: 'bars?!?!!?'
          datetime: new Date().toISOString()
          place:
            name: 'B Bar & Grill'
            geo:
              type: 'Point'
              coordinates: [40.7270718, -73.9919324]
          comment: 'awwww yisssss'
          canceled: false
          created_at: new Date().toISOString()
          updated_at: new Date().toISOString()

      it 'should return the deserialized event', ->
        expectedEvent =
          id: response.id
          creatorId: response.creator
          title: response.title
          datetime: new Date response.datetime
          place:
            name: response.place.name
            lat: response.place.geo.coordinates[0]
            long: response.place.geo.coordinates[1]
          comment: 'awwww yisssss'
          canceled: response.canceled
          createdAt: new Date response.created_at
          updatedAt: new Date response.updated_at
        expect(Event.deserialize response).toAngularEqual expectedEvent


  describe 'creating', ->
    event = null
    response = null
    responseData = null
    requestData = null

    beforeEach ->
      event =
        title: 'bars?!?!!?'
        creatorId: 1
        datetime: new Date()
        place:
          name: 'B Bar & Grill'
          lat: 40.7270718
          long: -73.9919324
        comment: 'awwww yisssss'
      requestData = Event.serialize event

    describe 'successfully', ->
      messagesDeferred = null

      beforeEach ->
        messagesDeferred = $q.defer()
        Messages.insert.and.returnValue {remote: messagesDeferred.promise}

        jasmine.clock().install()
        date = new Date 1438195002656
        jasmine.clock().mockDate date

        responseData = angular.extend {id: 1}, requestData,
          place:
            name: event.place.name
            geo:
              type: 'Point'
              coordinates: [event.place.lat, event.place.long]
          canceled: false
          created_at: new Date()
          updated_at: new Date()

        $httpBackend.expectPOST listUrl, requestData
          .respond 201, angular.toJson(responseData)

        response = null
        Event.save event
          .$promise.then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      afterEach ->
        jasmine.clock().uninstall()

      it 'should POST the event', ->
        expectedEvent = Event.deserialize responseData
        expect(response).toAngularEqual expectedEvent

      it 'should get the messages collection', ->
        expect(Asteroid.getCollection).toHaveBeenCalledWith 'messages'

      it 'should create a maybe action message', ->
        message =
          creator:
            id: "#{Auth.user.id}" # meteor likes strings
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: "#{Auth.user.name} might be down."
          eventId: "#{responseData.id}" # meteor likes strings
          type: Invitation.maybeAction
          createdAt:
            $date: new Date().getTime()
        expect(Messages.insert).toHaveBeenCalledWith message

      describe 'when the message saves', ->
        messageId = null

        beforeEach ->
          messageId = 'asdf'
          messagesDeferred.resolve messageId
          $rootScope.$apply()

        it 'should mark the message as read', ->
          expect(Asteroid.call).toHaveBeenCalledWith 'readMessage', messageId


    describe 'unsuccessfully', ->
      rejected = null

      beforeEach ->
        $httpBackend.expectPOST listUrl, requestData
          .respond 500, ''

        rejected = false
        Event.save event
          .$promise.then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


  describe 'sending a message', ->
    event = null
    text = null
    url = null
    requestData = null

    beforeEach ->
      # Mock the current user.
      Auth.user = id: 1

      event =
        id: 1
        creatorId: 1
        title: 'bars?!?!!?'
        datetime: new Date()
        canceled: false
        createdAt: new Date()
        updatedAt: new Date()
      text = 'I\'m in love with a robot.'
      url = "#{listUrl}/#{event.id}/messages"
      requestData = {text: text}

    describe 'successfully', ->
      resolved = false

      beforeEach ->
        jasmine.clock().install()
        date = new Date 1438195002656
        jasmine.clock().mockDate date

        $httpBackend.expectPOST url, requestData
          .respond 201, null

        Event.sendMessage(event, text).then ->
          resolved = true
        $httpBackend.flush 1

      afterEach ->
        jasmine.clock().uninstall()

      it 'should resolve the promise', ->
        expect(resolved).toBe true

      it 'should get the messages collection', ->
        expect(Asteroid.getCollection).toHaveBeenCalledWith 'messages'

      it 'should save the message in the meteor server', ->
        message =
          creator:
            id: "#{Auth.user.id}"
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: text
          eventId: "#{event.id}"
          type: 'text'
          createdAt:
            $date: new Date().getTime()
        expect(Messages.insert).toHaveBeenCalledWith message


    describe 'unsuccessfully', ->
      rejected = false

      beforeEach ->
        $httpBackend.expectPOST url, requestData
          .respond 500, null

        Event.sendMessage(event, text).then null, ->
          rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


  describe 'canceling', ->

    it 'should DELETE the event', ->
      event =
        id: 1
        creatorId: 1
        title: 'bars?!?!!?'
        datetime: new Date()
        canceled: false
        createdAt: new Date()
        updatedAt: new Date()

      $httpBackend.expectDELETE "#{listUrl}/#{event.id}"
        .respond 200

      # TODO: Figure out how to remove excess params in a delete request so that we
      # can just call `Event.cancel event`.
      Event.cancel {id: event.id}
      $httpBackend.flush 1


  describe 'getting the percent remaining for an event', ->
    currentDate = null
    event = null
    result = null

    beforeEach ->
      jasmine.clock().install()
      currentDate = new Date 1438014089235
      jasmine.clock().mockDate currentDate

      event = new Event
        id: 1
        creatorId: 1
        title: 'bars?!?!!?'
        canceled: false
        createdAt: new Date()
        updatedAt: new Date()

    afterEach ->
      jasmine.clock().uninstall()

    describe 'when the event has no datetime', ->

      beforeEach ->
        event.datetime = null
        currentHours = currentDate.getHours()
        event.createdAt = new Date().setHours currentHours-6

        result = event.getPercentRemaining()

      it 'should return the percentage', ->
        expect(result).toBe 75


    describe 'when the event has a datetime', ->

      beforeEach ->
        event.createdAt = new Date()
        event.createdAt.setDate currentDate.getDate()-2
        event.datetime = new Date()
        event.datetime.setDate currentDate.getDate()+1

        result = event.getPercentRemaining()

      it 'should return the percentage', ->
        expect(result).toBe 50


  describe 'getting invited ids', ->
    event = null
    url = null

    beforeEach ->
      event =
        id: 1
      url = "#{listUrl}/#{event.id}/invited-ids"

    describe 'when successful', ->

      it 'should resolve the promise with user ids', ->
        invitedIds = [1, 2, 3]

        $httpBackend.expectGET url
          .respond 200, invitedIds

        result = null
        Event.getInvitedIds(event).then (_result_) ->
          result = _result_
        $httpBackend.flush 1

        expect(result).toEqual invitedIds


    describe 'when error', ->

      it 'should reject the promise', ->
        # TODO : Is this the right status code?
        $httpBackend.expectGET url
          .respond 400

        rejected = null
        Event.getInvitedIds(event).then null, ->
          rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true
