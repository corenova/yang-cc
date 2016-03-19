# core - the embodiment of the soul of the application
console.debug ?= console.log if process.env.yang_debug?

yang     = require 'yang-js'
events   = require 'events'
assert   = require 'assert'
tosource = require 'tosource'

class Core extends yang.Yang
  @mixin events.EventEmitter

  run: ->
    @invoke 'main', arguments...

  dump: (opts={}) ->
    console.log @origin.toString()

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
