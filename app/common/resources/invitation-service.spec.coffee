require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'invitation service', ->
  $httpBackend = null
  Invitation = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    Invitation = $injector.get 'Invitation'
    User = $injector.get 'User'

    listUrl = "#{apiRoot}/invitations"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  it 'should have a no response property', ->
    expect(Invitation.noResponse).toBe 0

  it 'should have an accepted property', ->
    expect(Invitation.accepted).toBe 1

  it 'should have a declined property', ->
    expect(Invitation.declined).toBe 2

  it 'should have a maybe property', ->
    expect(Invitation.maybe).toBe 3

  describe 'serializing an invitation', ->

    it 'should return the serialized invitation', ->
      invitation =
        id: 1
        eventId: 2
        toUserId: 3
        fromUserId: 4
        response: Invitation.accepted
        previouslyAccepted: false
        open: false
        toUserMessaged: false
        muted: false
        createdAt: new Date()
        updatedAt: new Date()
      expectedInvitation =
        id: invitation.id
        event: invitation.eventId
        to_user: invitation.toUserId
        from_user: invitation.fromUserId
        response: invitation.response
        previously_accepted: invitation.previouslyAccepted
        open: invitation.open
        to_user_messaged: invitation.toUserMessaged
        muted: invitation.muted
        created_at: invitation.createdAt.getTime()
        updated_at: invitation.updatedAt.getTime()
      expect(Invitation.serialize invitation).toEqual expectedInvitation


  describe 'deserializing an invitation', ->

    it 'should return the deserialized invitation', ->
      response =
        id: 1
        event: 2
        to_user: 3
        from_user: 4
        response: Invitation.accepted
        previously_accepted: false
        open: false
        to_user_messaged: false
        muted: false
        created_at: new Date().getTime()
        updated_at: new Date().getTime()
      expectedInvitation =
        id: response.id
        eventId: response.event
        toUserId: response.to_user
        fromUserId: response.from_user
        response: response.response
        previouslyAccepted: response.previously_accepted
        open: response.open
        toUserMessaged: response.to_user_messaged
        muted: response.muted
        createdAt: new Date(response.created_at)
        updatedAt: new Date(response.updated_at)
      expect(Invitation.deserialize response).toEqual expectedInvitation


  describe 'creating', ->

    it 'should POST the invitation', ->
      invitation =
        eventId: 1
        toUserId: 2
        fromUserId: 3
        response: Invitation.noResponse
        previouslyAccepted: false
        open: false
        toUserMessaged: false
        muted: false
        createdAt: new Date()
        updatedAt: new Date()
      postData = Invitation.serialize invitation
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      Invitation.save(invitation).$promise.then (_response_) ->
        response = _response_
      $httpBackend.flush 1

      expectedInvitationData = angular.extend {id: responseData.id}, invitation
      expectedInvitation = new Invitation(expectedInvitationData)
      expect(response).toAngularEqual expectedInvitation


  describe 'bulk creating', ->

    it 'should POST the invitations', ->
      invitation1 =
        eventId: 1
        toUserId: 2
        fromUserId: 3
        response: Invitation.noResponse
        previouslyAccepted: false
        open: false
        toUserMessaged: false
        muted: false
        createdAt: new Date()
        updatedAt: new Date()
      invitation2 = angular.extend {}, invitation1, {toUserId: 3}
      invitations = [invitation1, invitation2]

      # Mock an array of invitations for the post data.
      invitationsPostData = []
      for invitation in invitations
        invitationsPostData.push Invitation.serialize(invitation)
      postData = invitations: invitationsPostData

      # Give each invitation in the post data a different id.
      responseData = []
      i = 1
      for invitation in invitationsPostData
        responseData.push angular.extend({id: i}, invitation)
        i += 1

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      Invitation.bulkCreate(invitations).$promise.then (_response_) ->
        response = _response_
      $httpBackend.flush 1

      # Set the returned ids on the original invitations.
      expectedInvitations = []
      i = 0
      for invitation in invitations
        invitation = angular.extend {id: responseData[i].id}, invitation
        expectedInvitations.push(new Invitation(invitation))
        i += 1
      expect(response).toAngularEqual expectedInvitations
