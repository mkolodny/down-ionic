class Utils
  underscore: (string) ->
    string.replace(/([A-Z])/g, '_$1').toLowerCase()

  camelize: (string) ->
    string.replace /_(.)/g, (match, char) -> char.toUpperCase()

  serialize: (data) ->
    @serializeObj data

  serializeObj: (obj) ->
    result = {}
    for key, val of obj
      if angular.isDate val
        result[@underscore(key)] = val.getTime()
      else if angular.isArray val
        result[@underscore(key)] = @serializeArray val
      else if angular.isObject val
        result[@underscore(key)] = @serializeObj val
      else
        result[@underscore(key)] = val
    result

  serializeArray: (array) ->
    result = []
    for obj in array
      result.push @serializeObj(obj)
    result

module.exports = Utils
