require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'allfriendsinvitation service', ->
  $httpBackend = null
  AllFriendsInvitation = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    AllFriendsInvitation = $injector.get 'AllFriendsInvitation'

    listUrl = "#{apiRoot}/all-friends-invitations"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'creating', ->

    it 'should POST the allFriendsInvitation', ->
      allFriendsInvitation =
        eventId: 1
        fromUserId: 2
        createdAt: new Date()
      postData =
        event_id: allFriendsInvitation.eventId
        from_user_id: allFriendsInvitation.fromUserId
        created_at: allFriendsInvitation.createdAt.getTime()
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      AllFriendsInvitation.save allFriendsInvitation
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedAllFriendsInvitationData = angular.extend {id: responseData.id}, allFriendsInvitation
      expectedAllFriendsInvitation = new AllFriendsInvitation(expectedAllFriendsInvitationData)
      expect(response).toAngularEqual expectedAllFriendsInvitation
