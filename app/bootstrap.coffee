# tells AngularJS to go ahead and bootstrap when the DOM is loaded
require './ionic/ionic.js'
angular = require 'angular'
require 'angular-animate'
require 'angular-sanitize'
require 'angular-ui-router'
require './ionic/ionic-angular.js'
require './app-module'

angular.element(document).ready ->
  try
    angular.bootstrap document, ['down']
  catch error
    console.error error.stack or error.message or error
