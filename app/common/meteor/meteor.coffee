# Define Local Mongo Collections
#   In controllers use $meteor.getCollectionByName 'messages'
new Mongo.Collection 'chats'
new Mongo.Collection 'messages'
