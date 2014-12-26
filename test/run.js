var hifive   = require('hifive')
var reporter = require('hifive-spec')()
var specs    = require('./specs')

hifive.runWithDefaults(specs, reporter)
