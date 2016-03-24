# core - the embodiment of the soul of the application

yang     = require 'yang-js'
events   = require 'events'
assert   = require 'assert'
fs       = require 'fs'

class Core extends yang.Yang
  @mixin events.EventEmitter

  constructor: -> @runtime = {}; super

  merge: ->
    modules = ([].concat arguments...).map (core) =>
      core = @origin.load core unless core instanceof Core
      @attach k, v for k, v of core.properties # how about methods?
      Object.keys core.properties
    [].concat modules...

  run: (feature, args...) ->
    f = @origin.resolve 'feature', feature
    @invoke f, args...
    .then (res) => @runtime[feature] = res
    .catch (err) -> console.error err

  dump: (opts={}) ->
    # force opts defaults (for now)
    opts.format = 'binary'

    res = super
    res = (new Buffer res).toString 'base64'
    res = """
    composition {
      type #{opts.format};
      reference \"#{res}\";
    }
    """
    if typeof opts.output is 'string'
      fs.writeFile opts.output, res, 'utf8'
    else
      console.info res
    return res

  ## OVERRIDES
  attach: -> super; @emit 'attach', arguments...

module.exports = Core
