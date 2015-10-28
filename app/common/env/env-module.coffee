### @if BUILD_ENV='prod' ###
window.__meteor_runtime_config__ = window.__meteor_runtime_config__ or
  DDP_DEFAULT_CONNECTION_URL: 'https://down-meteor.herokuapp.com'
apiRoot = window.ApiRoot or 'https://down-prod.herokuapp.com/api'
branchKey = window.BranchKey or 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
mixpanelToken = window.MixpanelToken or '14c9d01044b39cc2c5cfc2dc8efbe532'
skipIonicDeploy = false
ionicDeployChannel = 'production'
### @endif ###

### @if BUILD_ENV='staging' ###
window.__meteor_runtime_config__ = window.__meteor_runtime_config__ or
  DDP_DEFAULT_CONNECTION_URL: 'https://down-meteor-staging.herokuapp.com'
apiRoot = window.ApiRoot or 'https://down-staging.herokuapp.com/api'
branchKey = window.BranchKey or 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
mixpanelToken = window.MixpanelToken or 'd4d37f58ce26f5e423cbc6fa937c621b'
skipIonicDeploy = true
ionicDeployChannel = 'dev'
### @endif ###

### @if BUILD_ENV='local' ###
window.__meteor_runtime_config__ = window.__meteor_runtime_config__ or
  DDP_DEFAULT_CONNECTION_URL: 'http://localhost:3500'
apiRoot = window.ApiRoot or 'http://localhost:8000/api'
branchKey = window.BranchKey or 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
mixpanelToken = window.MixpanelToken or 'd4d37f58ce26f5e423cbc6fa937c621b'
skipIonicDeploy = true
ionicDeployChannel = 'dev'
### @endif ###

angular.module 'rallytap.env', []
  .constant 'skipIonicDeploy', skipIonicDeploy
  .constant 'apiRoot', apiRoot
  .constant 'branchKey', branchKey
  .constant 'mixpanelToken', mixpanelToken
  .constant 'ionicDeployChannel', ionicDeployChannel
  .constant 'androidSenderID', '189543748377'
