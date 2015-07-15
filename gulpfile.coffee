require 'coffee-script/register'
browserify = require 'browserify'
bower = require 'bower'
del = require 'del'
concat = require 'gulp-concat'
glob = require 'glob'
gulp = require 'gulp'
gutil = require 'gulp-util'
imagemin = require 'gulp-imagemin'
karma = require('karma').server
karmaConf = require './config/karma.conf'
minifyCss = require 'gulp-minify-css'
rename = require 'gulp-rename'
sass = require 'gulp-sass'
sh = require 'shelljs'
source = require 'vinyl-source-stream'
uglify = require 'gulp-uglify'
watchify = require 'watchify'
webdriverUpdate = require('gulp-protractor').webdriver_update
protractor = require('gulp-protractor').protractor

# TODO: Make sure that the order of tasks doesn't matter. If
# it does, use a callback:
# https://github.com/gulpjs/gulp/blob/master/docs/API.md#return-a-promise

buildDir = './www'
appDir = './app'
dataDir = './data'
testDir = './tests'

gulp.task 'install', ->
  bower.commands.install().on 'log', (data) ->
    gutil.log 'bower', gutil.colors.cyan(data.id), data.message


scripts = (watch) ->
  bundler = browserify
    cache: {}
    packageCache: {}
    entries: ["#{appDir}/bootstrap.coffee"]
    extensions: ['.coffee']
  if watch
    bundler = watchify bundler

  bundle = ->
    bundleStream = bundler.bundle()
      # use vinyl-source-stream to make the stream gulp compatible
      # specifiy the desired output filename here
      .pipe source('bundle.js')
      # wrap plugins to support streams
      # i.e. .pipe streamify(plugin())
      .pipe gulp.dest("#{buildDir}/app")
    return bundleStream

  if watch
    bundler.on 'update', bundle

  bundle()
  return


gulp.task 'scripts', ->
  scripts false
  return


gulp.task 'styles', ->
  gulp.src "#{appDir}/main.scss"
    .pipe sass(errLogToConsole: true)
    .pipe rename(extname: '.css')
    .pipe gulp.dest("#{buildDir}/app")
    #.pipe minifyCss(keepSpecialComments: 0)
    #.pipe rename(extname: '.min.css')
    #.pipe gulp.dest("#{buildDir}/app")
  return


gulp.task 'data', ->
  gulp.src "#{dataDir}/**/*", {base: "#{dataDir}"}
    .pipe gulp.dest(buildDir)
  return


gulp.task 'templates', ->
  # NOTE: When we build the webview, we can give the ionic templates/partials an
  # .app.html extension, and the web partials a .web.html extension, then rename them
  # to .html. If we decide to use gulp-template-cache, we can us the transformUrl
  # option.
  gulp.src [
    "#{appDir}/**/*.html"
    "!#{appDir}/index.html"
  ], {base: "#{appDir}"}
    .pipe gulp.dest("#{buildDir}/app")

  gulp.src "#{appDir}/index.html"
    .pipe gulp.dest(buildDir)
  return


gulp.task 'minify-js', ->
  gulp.src "#{buildDir}/app/bundle.js"
    .pipe uglify({mangle: false})
    .pipe gulp.dest("#{buildDir}/app")
  return


gulp.task 'minify-css', ->
  gulp.src "#{buildDir}/app/main.css"
    .pipe minifyCSS()
    .pipe gulp.dest("#{buildDir}/app")
  return


gulp.task 'minify-images', ->
  gulp.src "#{buildDir}/images/**/*"
    .pipe imagemin()
    .pipe gulp.dest("#{buildDir}/images")
  return


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
  return


gulp.task 'webdriver-update', webdriverUpdate


gulp.task 'e2e', ['webdriver-update'], ->
  gulp.src "#{appDir}/**/*.scenario.coffee"
    .pipe protractor(configFile: './client/config/protractor.conf.coffee')
    .on 'error', (error) ->
      throw error
  return


gulp.task 'clean', ->
  del 'www'
  return


gulp.task 'build', [
  'clean'
  'scripts'
  'styles'
  'templates'
  'data'
  'minify'
]


gulp.task 'watch', [
  'clean'
  'scripts'
  'styles'
  'templates'
  'data'
], ->
  scripts true
  gulp.watch "#{appDir}/**/*.scss", ['styles']
  gulp.watch "#{dataDir}/**/*", ['data']
  gulp.watch "#{appDir}/**/*.html", ['templates']
  return


gulp.task 'default', ['watch']
