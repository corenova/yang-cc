# Composer - wrapper around yang-js to provide gcc-style compilations
#
# composes local file assets into a generated output

yang = require 'yang-js'
Core = require './core'
SearchPath = require 'search-path'

class Composer extends yang.Yin

  # it defaults to adopting the 'yang' instance as its origin for
  # symbolic resolution
  constructor: (origin=yang) ->
    super origin
    # TODO: prevent pulling the entire 'extension' obj into current @map
    @define 'extension',
      composition:
        type:      '1'
        reference: '1'
        preprocess: (arg, params, ctx) ->
          data = (new Buffer params.reference, 'base64').toString 'binary'
          ctx[k] = v for k, v of (yang.parse data)

    @includes = new SearchPath basedir: __dirname, exts: [ 'yaml', 'yml', 'yang' ]
    @links    = new SearchPath basedir: __dirname, exts: [ 'js', 'coffee' ]
    if origin instanceof Composer
      @includes.include origin.includes...
      @links.include origin.links...

  # register spec/schema search directories (exists)
  include: ->
    @includes
      .base @resolve 'basedir', warn: false
      .include ([].concat arguments...)
    return this

  # register feature search directories (exists)
  link: ->
    @links
      .base @resolve 'basedir', warn: false
      .include ([].concat arguments...)
    return this

  # accepts: core/schema/spec file locations
  # returns: a new Core object
  compose: ->
    @load (@includes.fetch ([].concat arguments...))

  ## OVERRIDES

  # accepts: core/schema/spec objects and strings
  # returns: a new Core object
  load: ->
    input = [].concat arguments...
    unless input.length > 0
      throw @error "no input schema(s) to load"
    new Core ((new Composer this).use input)

  # extends resolve to attempt to generate missing symbols
  resolve: (keys..., opts={}) ->
    unless opts instanceof Object
      keys.push opts
      opts = {}
    return unless keys.length > 0

    match = super keys..., warn: false
    match ?= switch
      when keys.length is 1
        @use (@includes.fetch keys[0])...
        super keys[0], recurse: false
      when keys[0] in [ 'feature', 'rpc' ] and opts.module?
        [ type, key ] = keys
        loc = (@links.resolve "#{opts.module}/#{type}/#{key}")[0]
        @set type, key, switch
          when loc?
            res = require loc
            res.__origin__ = loc
            res
          else {}
        super type, key, recurse: false
    return match

module.exports = Composer
