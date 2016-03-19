# yangforge - load and build cores

Composer = require './composer'

#
# declare exports
#
exports = module.exports = (new Composer).include '../standard'
exports.Composer = Composer
exports.Core = require './core'
