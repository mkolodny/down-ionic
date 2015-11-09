require 'angular'
require 'angular-mocks'
require '../auth/auth-module'
require './resources-module'
require '../meteor/meteor-mocks'

describe 'event service', ->
  $filter = null
  $httpBackend = null
  $rootScope = null
  $meteor = null
  $q = null
  Auth = null
  Event = null
  Friendship = null
  Invitation = null
  Messages = null
  User = null
  listUrl = null

  beforeEach angular.mock.module('angular-meteor')

  beforeEach angular.mock.module('rallytap.resources')

  beforeEach angular.mock.module('rallytap.auth')

  beforeEach angular.mock.module(($provide) ->
    # Mock a logged in user.
    Auth =
      user:
        id: 1
        name: 'Alan Turing'
        firstName: 'Alan'
        lastName: 'Turing'
        imageUrl: 'http://facebook.com/profile-pic/tdog'
      addPoints: jasmine.createSpy 'Auth.addPoints'
      Points:
        sentInvitation: 1
    $provide.value 'Auth', Auth
    return
  )

  beforeEach inject(($injector) ->
    $filter = $injector.get '$filter'
    $httpBackend = $injector.get '$httpBackend'
    $rootScope = $injector.get '$rootScope'
    $meteor = $injector.get '$meteor'
    $q = $injector.get '$q'
    apiRoot = $injector.get 'apiRoot'
    User = $injector.get 'User'
    Event = $injector.get 'Event'
    Friendship = $injector.get 'Friendship'
    Invitation = $injector.get 'Invitation'

    # Mock Messages collection
    Messages =
      insert: jasmine.createSpy 'Messages.insert'
    $meteor.getCollectionByName.and.returnValue Messages

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
          createdAt: new Date()
          updatedAt: new Date()
          invitations: invitations
          minAccepted: 5

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
          invitations: invitations
          min_accepted: 5
        expect(Event.serialize event).toEqual expectedEvent


  describe 'deserializing an event', ->
    response = null

    describe 'with the min amount of data', ->

      beforeEach ->
        response =
          id: 1
          creator: 1
          title: 'bars?!?!!?'
          created_at: new Date().toISOString()
          updated_at: new Date().toISOString()

      it 'should return the deserialized event', ->
        expectedEvent =
          id: response.id
          creatorId: response.creator
          title: response.title
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
          created_at: new Date().toISOString()
          updated_at: new Date().toISOString()
          min_accepted: 5

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
          createdAt: new Date response.created_at
          updatedAt: new Date response.updated_at
          minAccepted: 5
        expect(Event.deserialize response).toAngularEqual expectedEvent


  describe 'creating', ->
    event = null
    invitation = null
    response = null
    responseData = null
    requestData = null

    beforeEach ->
      invitation =
        to_user: 2
      event =
        title: 'bars?!?!!?'
        creatorId: 1
        datetime: new Date()
        place:
          name: 'B Bar & Grill'
          lat: 40.7270718
          long: -73.9919324
        invitations: [invitation]

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
          created_at: new Date()
          updated_at: new Date()

        $httpBackend.expectPOST listUrl, requestData
          .respond 201, angular.toJson(responseData)

        spyOn Event, 'readMessage'

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
        expect($meteor.getCollectionByName).toHaveBeenCalledWith 'messages'

      it 'should create an accept action message', ->
        message =
          creator:
            id: "#{Auth.user.id}" # meteor likes strings
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: "#{Auth.user.name} is down."
          chatId: "#{responseData.id}" # meteor likes strings
          type: Invitation.acceptAction
          createdAt: new Date()

        expect(Messages.insert).toHaveBeenCalledWith message, Event.readMessage

      it 'should add the points', ->
        expectedPoints = Auth.Points.sentInvitation * responseData.invitations.length
        expect(Auth.addPoints).toHaveBeenCalledWith expectedPoints

      it 'should create invite_action messages', ->
        inviteMessage =
          creator:
            id: "#{Auth.user.id}" # meteor likes strings
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: "#{Auth.user.firstName}: Down?"
          chatId: Friendship.getChatId invitation.to_user # meteor likes strings
          type: Invitation.inviteAction
          createdAt: new Date()
          meta:
            eventId: "#{responseData.id}"

        expect(Messages.insert).toHaveBeenCalledWith(inviteMessage,
            Event.readMessage)

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


  describe 'marking a message as read', ->
    messageId = null

    beforeEach ->
      error = null
      messageId = 'asdf'
      Event.readMessage error, messageId

    it 'should call readMessage with the message id', ->
      expect($meteor.call).toHaveBeenCalledWith 'readMessage', messageId


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

        Event.sendMessage event, text
          .then ->
            resolved = true
        $httpBackend.flush 1

      afterEach ->
        jasmine.clock().uninstall()

      it 'should resolve the promise', ->
        expect(resolved).toBe true

      it 'should get the messages collection', ->
        expect($meteor.getCollectionByName).toHaveBeenCalledWith 'messages'

      it 'should save the message in the meteor server', ->
        message =
          creator:
            id: "#{Auth.user.id}"
            name: Auth.user.name
            firstName: Auth.user.firstName
            lastName: Auth.user.lastName
            imageUrl: Auth.user.imageUrl
          text: text
          chatId: "#{event.id}"
          type: 'text'
          createdAt: new Date()
        expect(Messages.insert).toHaveBeenCalledWith message


    describe 'unsuccessfully', ->
      rejected = false

      beforeEach ->
        $httpBackend.expectPOST url, requestData
          .respond 500, null

        Event.sendMessage event, text
          .then null, ->
            rejected = true
        $httpBackend.flush 1

      it 'should reject the promise', ->
        expect(rejected).toBe true


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
        Event.getInvitedIds event
          .then null, ->
            rejected = true
        $httpBackend.flush 1

        expect(rejected).toBe true


  describe 'getting the event\'s share message', ->
    eventMessage = null
    event = null

    beforeEach ->
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
      event = new Event event

    describe 'when the event has all possible properties', ->

      beforeEach ->
        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        date = $filter('date') event.datetime, "EEE, MMM d 'at' h:mm a"
        message = "#{event.title} at #{event.place.name} — #{date}"
        expect(eventMessage).toBe message


    describe 'when the event has a title and place', ->

      beforeEach ->
        delete event.datetime

        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        message = "#{event.title} at #{event.place.name}"
        expect(eventMessage).toBe message


    describe 'when the event has a title and datetime', ->

      beforeEach ->
        delete event.place

        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        date = $filter('date') event.datetime, "EEE, MMM d 'at' h:mm a"
        message = "#{event.title} — #{date}"
        expect(eventMessage).toBe message


    describe 'when the event only has a title', ->

      beforeEach ->
        delete event.place
        delete event.datetime

        eventMessage = event.getEventMessage()

      it 'should return the message', ->
        expect(eventMessage).toBe event.title

