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

    listUrl = "#{apiRoot}/invitations"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  serializeInvitation = (invitation) ->
    invitation =
      event_id: invitation.eventId
      to_user_id: invitation.toUserId
      from_user_id: invitation.fromUserId
      response: invitation.response
      previously_accepted: invitation.previouslyAccepted
      open: invitation.open
      to_user_messaged: invitation.toUserMessaged
      muted: invitation.muted
      created_at: invitation.createdAt.getTime()
      updated_at: invitation.updatedAt.getTime()
    invitation

  describe 'creating', ->

    it 'should POST the invitation', ->
      invitation =
        eventId: 1
        toUserId: 2
        fromUserId: 3
        response: 0
        previouslyAccepted: false
        open: false
        toUserMessaged: false
        muted: false
        createdAt: new Date()
        updatedAt: new Date()
      postData = serializeInvitation invitation
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
        response: 0
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
        invitationsPostData.push serializeInvitation(invitation)
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
