require 'angular'

### @if BUILD_ENV='prod' ###
meteorHost = 'https://down-meteor.herokuapp.com'
angular.module 'down.env', []
  ## Prod vars
  .constant 'skipIonicDeploy', false
  .constant 'apiRoot', 'https://down-prod.herokuapp.com/api'
  .constant 'branchKey', 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
  .constant 'mixpanelToken', '14c9d01044b39cc2c5cfc2dc8efbe532'
  .constant 'ionicDeployChannel', 'staging'
### @endif ###

### @if BUILD_ENV='staging' ###
meteorHost = 'https://down-meteor-staging.herokuapp.com'
angular.module 'down.env', []
  ## Staging vars
  .constant 'skipIonicDeploy', true
  .constant 'apiRoot', 'http://down-staging.herokuapp.com/api'
  .constant 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  .constant 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'
  .constant 'ionicDeployChannel', 'dev'
### @endif ###

### @if BUILD_ENV='local' ###
meteorHost = 'http://localhost:3500'
angular.module 'down.env', []
  ## Dev vars
  .constant 'skipIonicDeploy', true
  .constant 'apiRoot', 'http://localhost:8000/api'
  .constant 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  .constant 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'
  .constant 'ionicDeployChannel', 'dev'
### @endif ###

# Set global meteor host variable
window.__meteor_runtime_config__ =
  DDP_DEFAULT_CONNECTION_URL: meteorHost