require './ionic/ionic.io.min.js'

bootstrapAngular = ->
  # Tell AngularJS to go ahead and 
  #   bootstrap when the DOM is loaded
  require './app-module'
  angular.element(document).ready ->
    try
      angular.bootstrap document, ['rallytap']
    catch error
      console.log error
      console.error error.stack or error.message or error

scriptsInjected = 0
scriptsLoaded = 0

scriptLoaded = (scriptUrl) ->
  console.log "Loaded Script: #{scriptUrl}"
  scriptsLoaded++
  if scriptsLoaded is scriptsInjected
    bootstrapAngular()

injectScripts = (scriptsArray) ->
  for scriptUrl in scriptsArray
    console.log "Injecting Script: #{scriptUrl}"
    scriptsInjected++
    js = document.createElement('script')
    js.src = scriptUrl
    js.async = false
    document.head.appendChild js
    js.onload = scriptLoaded.bind this, scriptUrl

window.Ionic.io().onReady ->
  # Inject scripts that didn't get loaded 
  #   by the rallytap resources plugin

  # ionic
  if window.ionic is undefined
    scripts = [ 'https://d3r38ef3fjjz7g.cloudfront.net/vendor/ionic.min.js' ]
    injectScripts scripts
  # jquery
  #   note: jquery must be loaded before angular - needed for intl-phone
  if window.jQuery is undefined
    scripts = [ 'https://code.jquery.com/jquery-1.11.3.min.js' ]
    injectScripts scripts
  # angular
  if window.angular is undefined
    scripts = [
      'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.3.13/angular.min.js'
      'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.3.13/angular-animate.min.js'
      'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.3.13/angular-sanitize.min.js'
      'https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.13/angular-ui-router.min.js'
      'https://d3r38ef3fjjz7g.cloudfront.net/vendor/ionic-angular.min.js'
      'https://d3r38ef3fjjz7g.cloudfront.net/vendor/Chart.min.js'
      'https://d3r38ef3fjjz7g.cloudfront.net/vendor/angular-chart.min.js'
      'https://d3r38ef3fjjz7g.cloudfront.net/vendor/ng-cordova.min.js'
    ]
    injectScripts scripts
  # Meteor
  if window.Meteor is undefined
    scripts = [ 'https://d3r38ef3fjjz7g.cloudfront.net/vendor/meteor.min.js' ]
    injectScripts scripts

  if scriptsInjected is 0
    bootstrapAngular()