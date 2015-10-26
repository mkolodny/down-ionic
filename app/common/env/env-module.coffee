### @if BUILD_ENV='prod' ###
window.__meteor_runtime_config__ =
  DDP_DEFAULT_CONNECTION_URL: 'https://down-meteor.herokuapp.com'
angular.module 'rallytap.env', []
  ## Prod vars
  .constant 'skipIonicDeploy', false
  .constant 'apiRoot', 'https://down-prod.herokuapp.com/api'
  .constant 'branchKey', 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
  .constant 'mixpanelToken', '14c9d01044b39cc2c5cfc2dc8efbe532'
  .constant 'ionicDeployChannel', 'production'
  .constant 'androidSenderID', '189543748377'
### @endif ###

### @if BUILD_ENV='staging' ###
window.__meteor_runtime_config__ =
  DDP_DEFAULT_CONNECTION_URL: 'https://down-meteor-staging.herokuapp.com'
angular.module 'rallytap.env', []
  ## Staging vars
  .constant 'skipIonicDeploy', true
  .constant 'apiRoot', 'https://down-staging.herokuapp.com/api'
  .constant 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  .constant 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'
  .constant 'ionicDeployChannel', 'dev'
  .constant 'androidSenderID', '189543748377'
### @endif ###

### @if BUILD_ENV='local' ###
window.__meteor_runtime_config__ =
  DDP_DEFAULT_CONNECTION_URL: 'http://localhost:3500'
angular.module 'rallytap.env', []
  ## Dev vars
  .constant 'skipIonicDeploy', true
  .constant 'apiRoot', 'http://localhost:8000/api'
  .constant 'branchKey', 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
  .constant 'mixpanelToken', 'd4d37f58ce26f5e423cbc6fa937c621b'
  .constant 'ionicDeployChannel', 'dev'
  .constant 'androidSenderID', '189543748377'
### @endif ###
