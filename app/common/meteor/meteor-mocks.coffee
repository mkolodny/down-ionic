class Cursor
  forEach: jasmine.createSpy 'Cursor.forEach'
  map: jasmine.createSpy 'Cursor.map'
  fetch: jasmine.createSpy 'Cursor.fetch'
  count: jasmine.createSpy 'Cursor.count'
  observe: jasmine.createSpy 'Cursor.observe'
  observeChanges: jasmine.createSpy 'Cursor.observeChanges'

class Collection
  find: ->
    new Cursor()
  findOne: jasmine.createSpy 'Collection.findOne'
  insert: jasmine.createSpy 'Collection.insert'
  update: jasmine.createSpy 'Collection.update'
  upsert: jasmine.createSpy 'Collection.upsert'
  remove: jasmine.createSpy 'Collection.remove'
  allow: jasmine.createSpy 'Collection.allow'
  deny: jasmine.createSpy 'Collection.deny'

angular.module('angular-meteor', [])
.service '$meteor', ->
  @collection = jasmine.createSpy '$meteorCollection'
  @collectionFS = jasmine.createSpy '$meteorCollectionFS'
  @object = jasmine.createSpy '$meteorObject'
  @subscribe = jasmine.createSpy '$meteorSubscribe.subscribe'
  @call = jasmine.createSpy '$meteorMethods.call'
  @loginWithPassword = jasmine.createSpy '$meteorUser.loginWithPassword'
  @requireUser = jasmine.createSpy '$meteorUser.requireUser'
  @requireValidUser = jasmine.createSpy '$meteorUser.requireValidUser'
  @waitForUser = jasmine.createSpy '$meteorUser.waitForUser'
  @createUser = jasmine.createSpy '$meteorUser.createUser'
  @changePassword = jasmine.createSpy '$meteorUser.changePassword'
  @forgotPassword = jasmine.createSpy '$meteorUser.forgotPassword'
  @resetPassword = jasmine.createSpy '$meteorUser.resetPassword'
  @verifyEmail = jasmine.createSpy '$meteorUser.verifyEmail'
  @loginWithMeteorDeveloperAccount = jasmine.createSpy '$meteorUser.loginWithMeteorDeveloperAccount'
  @loginWithFacebook = jasmine.createSpy '$meteorUser.loginWithFacebook'
  @loginWithGithub = jasmine.createSpy '$meteorUser.loginWithGithub'
  @loginWithGoogle = jasmine.createSpy '$meteorUser.loginWithGoogle'
  @loginWithMeetup = jasmine.createSpy '$meteorUser.loginWithMeetup'
  @loginWithTwitter = jasmine.createSpy '$meteorUser.loginWithTwitter'
  @loginWithWeibo = jasmine.createSpy '$meteorUser.loginWithWeibo'
  @logout = jasmine.createSpy '$meteorUser.logout'
  @logoutOtherClients = jasmine.createSpy '$meteorUser.logoutOtherClients'
  @session = jasmine.createSpy '$meteorSession'
  @autorun = jasmine.createSpy '$meteorUtils.autorun'
  @getCollectionByName = jasmine.createSpy('$meteorUtils.getCollectionByName').and.returnValue new Collection()
  @getPicture = jasmine.createSpy '$meteorCamera.getPicture'
  return