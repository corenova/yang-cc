# yangforge - load and build cores

Composer = require './composer'

#
# declare exports
#
exports = module.exports =
  (new Composer)
    .include '..', '../standard'
    .use 'yang-composition'

exports.Composer = Composer
exports.Core = require './core'
