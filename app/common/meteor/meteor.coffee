require './meteor-client-side.js'
require './accounts-base-client-side.js'
require './accounts-password-client-side.js'
require './angular-meteor.js'

# Define Local Mongo Collections
#   In controllers use $meteor.getCollectionByName 'messages'
Chats = new Mongo.Collection 'chats'
Messages = new Mongo.Collection 'messages'
Comments = new Mongo.Collection 'comments'

# Subscribe to all chats
Meteor.subscribe 'allChats', ->
  Tracker.autorun ->
    allChats = Chats.find().fetch()
    chatIds = (chat._id for chat in allChats)
    Meteor.subscribe 'messages', chatIds