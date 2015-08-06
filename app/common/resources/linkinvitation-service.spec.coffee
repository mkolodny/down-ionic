require 'angular'
require 'angular-mocks'
require './resources-module'

describe 'linkinvitation service', ->
  $httpBackend = null
  LinkInvitation = null
  listUrl = null

  beforeEach angular.mock.module('down.resources')

  beforeEach inject(($injector) ->
    $httpBackend = $injector.get '$httpBackend'
    apiRoot = $injector.get 'apiRoot'
    LinkInvitation = $injector.get 'LinkInvitation'

    listUrl = "#{apiRoot}/link-invitations"
  )

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'creating', ->

    it 'should POST the linkInvitation', ->
      linkInvitation =
        eventId: 1
        fromUserId: 2
        linkId: 'asdf'
        createdAt: new Date()
      postData =
        event_id: linkInvitation.eventId
        from_user_id: linkInvitation.fromUserId
        link_id: 'asdf'
        created_at: linkInvitation.createdAt.getTime()
      responseData = angular.extend {id: 1}, postData

      $httpBackend.expectPOST listUrl, postData
        .respond 201, angular.toJson(responseData)

      response = null
      LinkInvitation.save linkInvitation
        .$promise.then (_response_) ->
          response = _response_
      $httpBackend.flush 1

      expectedLinkInvitationData = angular.extend {id: responseData.id},
          linkInvitation
      expectedLinkInvitation = new LinkInvitation(expectedLinkInvitationData)
      expect(response).toAngularEqual expectedLinkInvitation
