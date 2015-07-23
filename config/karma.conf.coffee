# Karma configuration

module.exports =
  basePath: ''

  frameworks: ['jasmine']

  files: ['./tests/test-bundle.js']

  exclude: []

  preprocessors: {}

  reporters: ['progress']

  port: 9876

  colors: true

  #logLevel: config.LOG_INFO

  autoWatch: true

  browsers: ['Chrome']

  singleRun: false

  browserDisconnectTimeout: 10000

  browserDisconnectTolerance: 1

  browserNoActivityTimeout: 60000
