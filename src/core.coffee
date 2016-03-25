# core - the embodiment of the soul of the application

yang   = require 'yang-js'
events = require 'events'
assert = require 'assert'

class Core extends yang.Yang
  @set synth: 'core'
  @mixin events.EventEmitter

  merge: ->
    cores = ([].concat arguments...).map (core) =>
      unless core instanceof Core
        @origin.load core
      else core
    return [] unless cores.length > 0

    @emit 'merge', cores...
    modules = cores.map (core) =>
      @attach k, v for k, v of core.properties # how about methods?
      Object.keys core.properties
    [].concat modules...

  run: (feature, args...) ->
    f = (@origin.resolve 'feature', feature)?.bind this
    assert f?,
      "cannot run with requested feature '#{feature}' (not found in the core)"
    @[feature] = f.apply this, args

  dump: (opts={}) ->
    # force opts defaults (for now)
    opts.format = 'binary'
    res = super
    res = (new Buffer res).toString 'base64'
    """
    composition {
      source \"#{res}\";
    }
    """

  attach: -> super; @emit 'attach', arguments...
  serialize: -> @get()

module.exports = Core
