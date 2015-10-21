require 'coffee-script/register'
autoprefixer = require 'gulp-autoprefixer'
argv = require('yargs').argv
browserify = require 'browserify'
bower = require 'bower'
childProcess = require 'child_process'
del = require 'del'
concat = require 'gulp-concat'
glob = require 'glob'
gulp = require 'gulp'
gutil = require 'gulp-util'
imagemin = require 'gulp-imagemin'
livereload = require 'gulp-livereload'
karma = require('karma').server
karmaConf = require './config/karma.conf'
minifyCss = require 'gulp-minify-css'
ngAnnotate = require 'gulp-ng-annotate'
preprocess = require 'gulp-preprocess'
rename = require 'gulp-rename'
runSequence = require 'run-sequence'
sass = require 'gulp-sass'
sh = require 'shelljs'
streamify = require 'gulp-streamify'
source = require 'vinyl-source-stream'
uglify = require 'gulp-uglify'
watchify = require 'watchify'
protractor = require('gulp-protractor').protractor
prompt = require 'prompt'

buildDir = './www'
appDir = './app'
dataDir = './data'
testDir = './tests'
vendorDir = './app/vendor'
resourcesScriptsDir = './resources/scripts'

scripts = (watch) ->
  bundler = browserify
    cache: {}
    packageCache: {}
    entries: ["#{appDir}/bootstrap.coffee"]
    extensions: ['.coffee']
  if watch
    bundler = watchify bundler

  # Check enviroment
  env = argv.e or 'staging'

  bundle = ->
    bundleStream = bundler.bundle()
      # use vinyl-source-stream to make the stream gulp compatible
      # specifiy the desired output filename here
      .pipe source('bundle.js')
      # wrap plugins to support streams
      # i.e. .pipe streamify(plugin())
      .pipe streamify(preprocess({context: {BUILD_ENV: env}}))
      .pipe gulp.dest("#{buildDir}/app")
    bundleStream

  if watch
    bundler.on 'update', bundle

  bundle()


gulp.task 'scripts', ->
  scripts false


gulp.task 'styles', ->
  gulp.src "#{appDir}/main.scss"
    .pipe sass(errLogToConsole: true)
    .pipe autoprefixer()
    .pipe rename(extname: '.css')
    .pipe gulp.dest("#{buildDir}/app")
    #.pipe minifyCss(keepSpecialComments: 0)
    #.pipe rename(extname: '.min.css')
    #.pipe gulp.dest("#{buildDir}/app")


gulp.task 'data', ->
  gulp.src "#{dataDir}/**/*", {base: "#{dataDir}"}
    .pipe gulp.dest(buildDir)


gulp.task 'templates', ->
  # Get the enviroment.
  env = argv.e or 'staging'

  # NOTE: When we build the webview, we can give the ionic templates/partials an
  #   .app.html extension, and the web partials a .web.html extension, then rename
  #   them to .html. If we decide to use gulp-template-cache, we can us the
  #   transformUrl option.
  gulp.src [
    "#{appDir}/**/*.html"
    "!#{appDir}/index.html"
  ], {base: "#{appDir}"}
    .pipe gulp.dest("#{buildDir}/app")

  gulp.src "#{appDir}/index.html"
    .pipe preprocess({context: {BUILD_ENV: env}})
    .pipe gulp.dest(buildDir)


gulp.task 'vendor', ->
  gulp.src "#{vendorDir}/**/*", {base: "#{appDir}"}
    .pipe gulp.dest("#{buildDir}/app")


###
# Minify the scripts to be included in the app bundle.
####
gulp.task 'resources-scripts', ->
  files = [
    'meteor.js'
    'ionic.js'
    'ionic-angular.js'
  ]
  for fileName in files
    gulp.src "#{resourcesScriptsDir}/#{fileName}"
      .pipe uglify()
      .pipe rename(extname: '.min.js')
      .pipe gulp.dest(resourcesScriptsDir)


gulp.task 'minify-js', ->
  gulp.src "#{buildDir}/app/bundle.js"
    .pipe ngAnnotate()
    .pipe uglify()
    .pipe gulp.dest("#{buildDir}/app")


gulp.task 'minify-css', ->
  gulp.src "#{buildDir}/app/main.css"
    .pipe minifyCss()
    .pipe gulp.dest("#{buildDir}/app")


gulp.task 'minify-images', ->
  gulp.src "#{buildDir}/images/**/*"
    .pipe imagemin()
    .pipe gulp.dest("#{buildDir}/images")


gulp.task 'minify', [
  'minify-js'
  'minify-css'
  'minify-images'
]


gulp.task 'unit', ->
  # Watch all test files for changes, and re-browserify.
  glob "#{appDir}/**/*.spec.coffee", null, (err, files) ->
    bundler = browserify
      cache: {}
      packageCache: {}
      entries: files
      extensions: ['.coffee']
    bundler = watchify bundler

    bundle = ->
      bundler.bundle()
        .pipe source('test-bundle.js')
        .pipe gulp.dest(testDir)

    bundler.on 'update', bundle

    bundle()

    # run the unit tests using karma
    karma.start karmaConf


gulp.task 'webdriver-update', (done) ->
  childProcess.spawn 'webdriver-manager', ['update'], stdio: 'inherit'
    .once 'close', done


gulp.task 'e2e', ['webdriver-update'], ->
  gulp.src "#{appDir}/**/*.scenario.coffee"
    .pipe protractor(configFile: './config/protractor.conf.coffee')
    .on 'error', (error) ->
      throw error


gulp.task 'clean', ->
  del 'www'


gulp.task 'build', [
  # 'clean'
  'scripts'
  'styles'
  'templates'
  'data'
  'vendor'
]


gulp.task 'watch', [
  'styles'
  'templates'
], ->
  scripts true
  gulp.watch "#{appDir}/**/*.scss", ['styles']
  gulp.watch "#{dataDir}/**/*", ['data']
  gulp.watch "#{vendorDir}/**/*", ['vendor']
  gulp.watch "#{appDir}/**/*.html", ['templates']
  childProcess.spawn 'serve', ['www', '--no-logs'], stdio: 'inherit'
  livereload.listen()
  gulp.watch "#{buildDir}/**/*"
    .on 'change', livereload.changed


gulp.task 'ionic-upload', (done) ->
  # Prompt for upload note
  prompt.message = 'Enter an upload note!'.green

  prompt.start()
  env = argv.e or 'unknown env'
  prompt.get [{name: env, required: true}], (err, result) ->
    if err then return console.log 'Error with prompt'

    # Set Ionic deploy tag
    if argv.e is 'prod'
      deployTag = 'production'
    else if argv.e is 'staging'
      deployTag = 'dev'
    else
      deployTag = 'dev'

    cmdArgs = ['upload', '--note', "#{env} - #{result[env]}", "--deploy=#{deployTag}"]
    childProcess.spawn 'ionic', cmdArgs, stdio: 'inherit'
      .once 'close', done


gulp.task 'deploy-staging', (done) ->
  argv.e = 'staging' # set env to staging

  runSequence(
    'build',
    'minify',
    'ionic-upload',
    done
  )


gulp.task 'deploy-prod', (done) ->
  argv.e = 'prod' # set env to prod

  runSequence(
    'build',
    'minify',
    'ionic-upload',
    done
  )


gulp.task 'default', ['watch']


# TODO:
# gulp run android
# gulp build android
# gulp build ios
