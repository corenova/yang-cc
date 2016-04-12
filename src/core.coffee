# core - the embodiment of the soul of the application

yang    = require 'yang-js'
events  = require 'events'
assert  = require 'assert'

browserify = require 'browserify'

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
      @attach k, v for k, v of core.properties
      @attach k, v for k, v of core.methods
      Object.keys core.properties
    [].concat modules...

  run: (feature, args...) ->
    f = (@origin.resolve 'feature', feature)?.bind this
    assert f?,
      "cannot run with requested feature '#{feature}' (not found in the core)"
    @[feature] = f.apply this, args

  # process of dumping the core requires async due to browserify
  #
  # returns: a new Promise for a serialized Core
  dump: (opts={}) ->
    objectify = @objectify
    linkers = (v for k, v of @origin.resolve 'link' when v instanceof Function)
    @invoke linkers
    .then (res) =>
      @origin.set 'link', x for x in res
      @origin.set opts.meta
      super opts.space

  attach: -> super; @emit 'attach', arguments...
  serialize: -> @get()

module.exports = Core
