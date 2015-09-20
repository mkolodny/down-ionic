require 'angular'

angular.module 'down.env', []
  ## Prod vars
  .value 'meteorHost', 'down-meteor.herokuapp.com'
  .value 'apiRoot', 'https://down-prod.herokuapp.com/api'
  .value 'branchKey', 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
  .value 'mixpanelToken', '14c9d01044b39cc2c5cfc2dc8efbe532'
  .value 'ionicDeployChannel', 'staging'

  ## Staging vars
  #.value 'meteorHost', 'down-meteor-staging.herokuapp.com'
  #.value 'apiRoot', 'http://down-staging.herokuapp.com/api'
  #.value 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  #.value 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'
  #.value 'ionicDeployChannel', 'dev'
  
  ## Dev vars
  #.value 'apiRoot', 'http://10.97.76.29:8000/api'
  #.value 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  #.value 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'

