require 'angular'
require 'angular-mocks'
require './utils-module'

describe 'utils service', ->
  Utils = null

  beforeEach angular.mock.module('down.utils')

  beforeEach inject(($injector) ->
    Utils = $injector.get 'Utils'
  )

  describe 'converting from camelcase to underscore', ->

    it 'should return an underscored string', ->
      expect(Utils.underscore 'eventId').toBe 'event_id'


  describe 'converting from underscore to camelcase', ->

    it 'should return a camelized string', ->
      expect(Utils.camelize 'event_id').toBe 'eventId'


  describe 'serializing data', ->

    it 'should underscore keys', ->
      data = {eventId: 1}
      expect(Utils.serialize data).toEqual {event_id: data.eventId}

    it 'should convert dates to timestamps', ->
      data = {datetime: new Date()}
      timestamp = data.datetime.getTime()
      expect(Utils.serialize data).toEqual {datetime: timestamp}

    it 'should handle nested objects', ->
      data =
        eventId: 1
        place:
          loc:
            geoId: 2
      expect(Utils.serialize data).toEqual
        event_id: data.eventId
        place:
          loc:
            geo_id: data.place.loc.geoId

    it 'should handle arrays of objects', ->
      invitation1 = toUserId: 1
      invitation2 = toUserId: 2
      data =
        invitations: [invitation1, invitation2]
      expect(Utils.serialize data).toEqual
        invitations: [
          to_user_id: invitation1.toUserId
        ,
          to_user_id: invitation2.toUserId
        ]
