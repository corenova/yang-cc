# core - the embodiment of the soul of the application

yang   = require 'yang-js'
events = require 'events'
assert = require 'assert'

class Core extends yang.Yang
  @mixin events.EventEmitter

  merge: ->
    modules = ([].concat arguments...).map (core) =>
      core = @origin.load core unless core instanceof Core
      @attach k, v for k, v of core.properties # how about methods?
      Object.keys core.properties
    [].concat modules...

  run: (feature, args...) ->
    f = (@origin.resolve 'feature', feature)?.bind this
    assert f?,
      "cannot run with requested feature '#{feature}' (not found in the core)"

    @[feature] =
      @invoke ((x..., y) -> y f x...), args...
      .catch (err) -> console.error err

  dump: (opts={}) ->
    # force opts defaults (for now)
    opts.format = 'binary'
    res = super
    res = (new Buffer res).toString 'base64'
    """
    composition {
      type #{opts.format};
      reference \"#{res}\";
    }
    """

  ## OVERRIDES
  attach: -> super; @emit 'attach', arguments...

module.exports = Core
