### @if BUILD_ENV='prod' ###
apiRoot = window.ApiRoot or 'https://down-prod.herokuapp.com/api'
branchKey = window.BranchKey or 'key_live_fihEW5pE0wsUP6nUmKi5zgfluBaUyQiJ'
mixpanelToken = window.MixpanelToken or '14c9d01044b39cc2c5cfc2dc8efbe532'
skipIonicDeploy = false
ionicDeployChannel = 'production'
### @endif ###

### @if BUILD_ENV='staging' ###
apiRoot = window.ApiRoot or 'https://down-staging.herokuapp.com/api'
branchKey = window.BranchKey or 'key_test_ogfq42bC7tuGVWdMjNm3sjflvDdOBJiv'
mixpanelToken = window.MixpanelToken or 'd4d37f58ce26f5e423cbc6fa937c621b'
skipIonicDeploy = false
ionicDeployChannel = 'dev'
### @endif ###

### @if BUILD_ENV='local' ###
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
