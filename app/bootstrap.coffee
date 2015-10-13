require './ionic/ionic.js'
window.$ = window.jQuery = require 'jquery' # jquery must be loaded before angular - needed for intl-phone
require 'angular'
require 'angular-animate'
require 'angular-sanitize'
require 'angular-ui-router'
require './ionic/ionic-angular.js'
require './app-module'

# Tell AngularJS to go ahead and bootstrap when the DOM is loaded
angular.element(document).ready ->
  try
    angular.bootstrap document, ['down']
  catch error
    console.log error
    console.error error.stack or error.message or error
