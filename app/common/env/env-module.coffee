require 'angular'

angular.module 'down.env', []
  ## Prod vars
  # .constant 'meteorHost', 'down-meteor.herokuapp.com'
  # .constant 'apiRoot', 'https://down-prod.herokuapp.com/api'
  # .constant 'branchKey', 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
  # .constant 'mixpanelToken', '14c9d01044b39cc2c5cfc2dc8efbe532'
  # .constant 'ionicDeployChannel', 'staging'

  ## Staging vars
  .constant 'meteorHost', 'down-meteor-staging.herokuapp.com'
  .constant 'apiRoot', 'http://down-staging.herokuapp.com/api'
  .constant 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  .constant 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'
  .constant 'ionicDeployChannel', 'dev'

  ## Dev vars
  #.constant 'apiRoot', 'http://10.97.76.29:8000/api'
  #.constant 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  #.constant 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'
