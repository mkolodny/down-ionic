require './meteor-client-side.js'
require './accounts-base-client-side.js'
require './accounts-password-client-side.js'
require './angular-meteor.js'

# Define Local Mongo Collections
#   In controllers use $meteor.getCollectionByName 'messages'
new Mongo.Collection 'chats'
new Mongo.Collection 'messages'
new Mongo.Collection 'comments'
