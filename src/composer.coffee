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
    @includes = new SearchPath basedir: __dirname, exts: [ 'yaml', 'yml', 'yang' ]
    @links    = new SearchPath basedir: __dirname, exts: [ 'js', 'coffee' ]
    if origin instanceof Composer
      @includes.include origin.includes...
      @links.include origin.links...
    else
      # TODO: consider making these part of yang-core-composer spec
      @define 'extension', 'composition',
        module: '0..n'
        specification: '0..n'
        feature: '0..n'
        source: '1'
        construct: (arg, params, children, ctx) ->
          console.debug? "passing through contents of composition"
          @copy ctx, children
          undefined
      @define 'extension', 'source',
        argument: 'data'
        preprocess: (arg, params, ctx) ->
          data = (new Buffer arg, 'base64').toString 'binary'
          { schema } = yang.preprocess data, this
          @copy ctx, schema
          delete ctx.source # no longer needed

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
      when 'module' is keys[0]
        @use (@includes.fetch keys[1])...
        super keys..., recurse: false
      when 'feature' is keys[0] and opts.module?
        loc = (@links.resolve [opts.module].concat(keys).join '/')[0]
        @set keys..., switch
          when loc?
            res = require loc
            res.__origin__ = loc
            res
          else
            console.debug? "unable to resolve '#{opts.module}/#{keys.join '/'}'"
            {}
        super keys..., recurse: false
      when 'rpc' is keys[0] and opts.module?
        loc = (@links.resolve [opts.module].concat(keys).join '/')[0]
        # TODO: should 'browserify' require loc and save it in 'specification'
        require loc if loc?
    return match

module.exports = Composer
