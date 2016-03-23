# core - the embodiment of the soul of the application

yang     = require 'yang-js'
events   = require 'events'
assert   = require 'assert'
fs       = require 'fs'

class Core extends yang.Yang
  @mixin events.EventEmitter

  run: ->
    @invoke 'main', arguments...

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

  enable: (feature, data, args...) ->
    Feature = @origin.resolve 'feature', feature
    assert Feature instanceof Function,
      "cannot enable incompatible feature"

    @once 'start', (engine) =>
      console.debug? "[Core:enable] starting with '#{feature}'"
      (new Feature data, this).invoke 'main', args...
      .then (res) -> console.log res
      .catch (err) -> console.error err

module.exports = Core
