### @if BUILD_ENV='prod' ###
window.__meteor_runtime_config__ =
  DDP_DEFAULT_CONNECTION_URL: 'https://down-meteor.herokuapp.com'
skipIonicDeploy = window.skipIonicDeploy or false
apiRoot = window.apiRoot or 'https://down-prod.herokuapp.com/api'
branchKey = window.branchKey or 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
mixpanelToken = window.mixpanelToken or '14c9d01044b39cc2c5cfc2dc8efbe532'
ionicDeployChannel = window.ionicDeployChannel or 'production'
androidSenderID = window.androidSenderID or '189543748377'
### @endif ###

### @if BUILD_ENV='staging' ###
window.__meteor_runtime_config__ =
  DDP_DEFAULT_CONNECTION_URL: 'https://down-meteor-staging.herokuapp.com'
skipIonicDeploy = window.skipIonicDeploy or true
apiRoot = window.apiRoot or 'https://down-staging.herokuapp.com/api'
branchKey = window.branchKey or 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
mixpanelToken = window.mixpanelToken or 'd4d37f58ce26f5e423cbc6fa937c621b'
ionicDeployChannel = window.ionicDeployChannel or 'dev'
androidSenderID = window.androidSenderID or '189543748377'
### @endif ###

### @if BUILD_ENV='local' ###
window.__meteor_runtime_config__ =
  DDP_DEFAULT_CONNECTION_URL: 'http://localhost:3500'
skipIonicDeploy = window.skipIonicDeploy or true
apiRoot = window.apiRoot or 'http://localhost:8000/api'
branchKey = window.branchKey or 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
mixpanelToken = window.mixpanelToken or 'd4d37f58ce26f5e423cbc6fa937c621b'
ionicDeployChannel = window.ionicDeployChannel or 'dev'
androidSenderID = window.androidSenderID or '189543748377'
### @endif ###

angular.module 'rallytap.env', []
  .constant 'skipIonicDeploy', skipIonicDeploy
  .constant 'apiRoot', apiRoot
  .constant 'branchKey', branchKey
  .constant 'mixpanelToken', mixpanelToken
  .constant 'ionicDeployChannel', ionicDeployChannel
  .constant 'androidSenderID', androidSenderID
