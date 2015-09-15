require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'linkinvitation service', ->
  $httpBackend = null
  Event = null
  Invitation = null
  LinkInvitation = null
  listUrl = null
  User = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'
    LinkInvitation = $injector.get 'LinkInvitation'
    User = $injector.get 'User'

    listUrl = "#{apiRoot}/link-invitations"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'serializing', ->
    linkInvitation = null
    serializedLinkInvitation = null

    beforeEach ->
      linkInvitation =
        eventId: 1
        fromUserId: 2
        linkId: 'asdf'
        createdAt: new Date()
      serializedLinkInvitation = LinkInvitation.serialize linkInvitation

    it 'should return the serialized link invitation', ->
      expectedLinkInvitation =
        event: linkInvitation.eventId
        from_user: linkInvitation.fromUserId
      expect(serializedLinkInvitation).toEqual expectedLinkInvitation


  describe 'deserializing', ->
    response = null
    linkInvitation = null

    describe 'with the min amount of data', ->

      beforeEach ->
        response =
          event: 1
          from_user: 2
          link_id: 'asdf'
          created_at: new Date().toISOString()
        linkInvitation = LinkInvitation.deserialize response

      it 'should return the serialized link invitation', ->
        expectedLinkInvitation =
          eventId: response.event
          fromUserId: response.from_user
          linkId: response.link_id
          createdAt: new Date response.created_at
        expect(linkInvitation).toEqual expectedLinkInvitation


    describe 'with the max amount of data', ->

      beforeEach ->
        response =
          event:
            id: 2
            creatorId: 3
            title: 'bars?!?!!?'
            createdAt: new Date().toISOString()
            updatedAt: new Date().toISOString()
          from_user:
            id: 4
            name: 'Alicia Vikander'
          invitation:
            id: 5
            event: 6
            from_user: 4
            to_user: 7
            response: Invitation.noResponse
          link_id: 'asdf'
          created_at: new Date().toISOString()
        linkInvitation = LinkInvitation.deserialize response

      it 'should return the serialized link invitation', ->
        expectedLinkInvitation =
          event: Event.deserialize response.event
          eventId: response.event.id
          fromUser: User.deserialize response.from_user
          fromUserId: response.from_user.id
          invitation: Invitation.deserialize response.invitation
          linkId: response.link_id
          createdAt: new Date response.created_at
        expect(linkInvitation).toAngularEqual expectedLinkInvitation


  describe 'creating', ->
    linkInvitation = null
    responseData = null
    response = null

    beforeEach ->
      linkInvitation =
        eventId: 1
        fromUserId: 2
        linkId: 'asdf'
        createdAt: new Date()
      postData = LinkInvitation.serialize linkInvitation
      responseData =
        id: 3
        event: linkInvitation.eventId
        from_user: linkInvitation.fromUserId
        link_id: linkInvitation.linkId
        created_at: linkInvitation.createdAt.toISOString()

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      LinkInvitation.save linkInvitation
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

    it 'should POST the linkInvitation', ->
      expectedLinkInvitation = LinkInvitation.deserialize responseData
      expect(response).toAngularEqual expectedLinkInvitation


  describe 'getting', ->
    linkId = null
    url = null

    beforeEach ->
      linkId = 'asdf'
      url = "#{listUrl}/#{linkId}"

    describe 'successfully', ->
      responseData = null
      response = null

      beforeEach ->
        responseData =
          id: 1
          event:
            id: 2
            creatorId: 3
            title: 'bars?!?!!?'
          from_user:
            id: 4
            name: 'Alicia Vikander'
          linkId: 'asdf'
          createdAt: new Date()
        $httpBackend.expectGET url
          .respond 200, angular.toJson(responseData)

        LinkInvitation.getByLinkId {linkId: linkId}
          .$promise.then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      it 'should GET the linkInvitation', ->
        expectedLinkInvitation = LinkInvitation.deserialize responseData
        expect(response).toAngularEqual expectedLinkInvitation


    describe 'with a 404', ->
      responseData = null
      response = null

      beforeEach ->
        $httpBackend.expectGET url
          .respond 404, {detail: 'Not found.'}

        LinkInvitation.getByLinkId {linkId: linkId}
          .$promise.then (_response_) ->
            response = _response_
        $httpBackend.flush 1

      it 'should return null', ->
        expect(response).toBeNull()
