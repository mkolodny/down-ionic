require 'angular'

angular.module 'down.env', []
  ## Prod vars
  .value 'host', 'down-meteor.herokuapp.com'
  .value 'apiRoot', 'https://down-prod.herokuapp.com/api'
  .value 'branchKey', 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
  ## Staging vars
  #.value 'host', 'down-meteor-staging.herokuapp.com'
  #.value 'apiRoot', 'http://down-staging.herokuapp.com/api'
  #.value 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  ## Dev vars
  #.value 'apiRoot', 'http://10.97.76.29:8000/api'
  #.value 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
