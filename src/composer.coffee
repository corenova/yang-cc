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
    @define 'extension',
      composition:
        type:    '1'
        default: '1'
        preprocess: (arg, params, ctx) ->
          data = (new Buffer params.default, 'base64').toString 'binary'
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
    res = (new Composer this).use ([].concat arguments...)
    new Core res.map

  # extends resolve to attempt to generate missing symbols
  resolve: (type, key, opts={}) ->
    match = super
    match ?= switch
      when not key?
        @use (@includes.fetch type)...
        super type, key, recurse: false
      when type is 'feature'
        loc = (@links.resolve key)[0]
        @set type, key, switch
          when loc? then require loc
          else {}
        super type, key, recurse: false
    return match

module.exports = Composer
