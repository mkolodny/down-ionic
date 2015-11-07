require 'angular'
require 'angular-mocks'
require 'ng-cordova'
require './resources-module'

describe 'linkinvitation service', ->
  $cordovaSocialSharing = null
  $httpBackend = null
  $ionicLoading = null
  $ionicPopup = null
  $mixpanel = null
  $q = null
  $rootScope = null
  $state = null
  $window = null
  Auth = null
  Event = null
  Invitation = null
  LinkInvitation = null
  listUrl = null
  User = null
  ngToast = null

  beforeEach angular.mock.module('rallytap.resources')
  
  beforeEach angular.mock.module('analytics.mixpanel')
  
  beforeEach angular.mock.module('ionic')
  
  beforeEach angular.mock.module('ngCordova')

  beforeEach angular.mock.module('ngToast')

  beforeEach inject(($injector) ->
    $cordovaSocialSharing = $injector.get '$cordovaSocialSharing'
    $httpBackend = $injector.get '$httpBackend'
    $ionicLoading = $injector.get '$ionicLoading'
    $ionicPopup = $injector.get '$ionicPopup'
    $mixpanel = $injector.get '$mixpanel'
    $q = $injector.get '$q'
    $rootScope = $injector.get '$rootScope'
    $state = $injector.get '$state'
    $window = $injector.get '$window'
    Auth = $injector.get 'Auth'
    apiRoot = $injector.get 'apiRoot'
    Event = $injector.get 'Event'
    Invitation = $injector.get 'Invitation'
    LinkInvitation = $injector.get 'LinkInvitation'
    User = $injector.get 'User'
    ngToast = $injector.get 'ngToast'

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

  ##share
  describe 'sharing a link invitation', ->
    deferred = null
    event = null

    beforeEach ->
      deferred = $q.defer()
      spyOn(LinkInvitation, 'save').and.returnValue {$promise: deferred.promise}
      spyOn $ionicLoading, 'show'
      spyOn $ionicLoading, 'hide'
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
      LinkInvitation.share event

    it 'should show a loading overlay', ->
      expect($ionicLoading.show).toHaveBeenCalled()

    it 'should create a link invitation', ->
      linkInvitation =
        eventId: event.id
        fromUserId: Auth.user.id
      expect(LinkInvitation.save).toHaveBeenCalledWith linkInvitation

    describe 'successfully', ->
      linkId = null

      beforeEach ->
        $state.current.name = 'some state'
        spyOn $mixpanel, 'track'

      describe 'when the social sharing plugin isn\'t installed', ->

        beforeEach ->
          $window.plugins = {}
          spyOn $ionicPopup, 'alert'

          linkId = 'mikepleb'
          deferred.resolve {linkId: linkId}
          $rootScope.$apply()

        it 'should show a modal with the share link', ->
          expect($ionicPopup.alert).toHaveBeenCalled()

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()

        it 'should track the event in mixpanel', ->
          expect($mixpanel.track).toHaveBeenCalledWith 'Get Link Invitation',
            'from screen': $state.current.name


      describe 'when the social sharing plugin is installed', ->
        eventMessage = null

        beforeEach ->
          $window.plugins =
            socialsharing: 'socialsharing'
          eventMessage = 'eventMessage'
          spyOn(event, 'getEventMessage').and.returnValue eventMessage
          spyOn $cordovaSocialSharing, 'share'

          linkId = 'mikepleb'
          deferred.resolve {linkId: linkId}
          $rootScope.$apply()

        it 'should show a native share sheet', ->
          message = eventMessage
          subject = eventMessage
          file = null
          link = "https://rallytap.com/e/#{linkId}"
          expect($cordovaSocialSharing.share).toHaveBeenCalledWith(message,
              subject, file, link)

        it 'should hide the loading overlay', ->
          expect($ionicLoading.hide).toHaveBeenCalled()
        
        it 'should track the event in mixpanel', ->
          expect($mixpanel.track).toHaveBeenCalledWith 'Get Link Invitation',
            'from screen': $state.current.name


    describe 'on error', ->

      beforeEach ->
        spyOn ngToast, 'create'

        deferred.reject()
        $rootScope.$apply()

      it 'should show an error', ->
        error = 'For some reason, that didn\'t work.'
        expect(ngToast.create).toHaveBeenCalledWith error

      it 'should hide the loading overlay', ->
        expect($ionicLoading.hide).toHaveBeenCalled()
